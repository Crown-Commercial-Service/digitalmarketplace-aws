data "aws_region" "current" {
  current = true
}

data "aws_ami" "nginx_ami" {
  owners = ["${var.ami_owner_account_id}"]
  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "tag:server-role"
    values = ["nginx"]
  }
  most_recent = true
}

resource "aws_autoscaling_group" "nginx_autoscaling_group" {
  name = "${var.name}"

  min_size = "${var.min_instance_count}"
  max_size = "${var.max_instance_count}"
  desired_capicity = "${var.instance_count}"

  health_check_type = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = ["${var.subnet_ids}"]

  load_balancers = ["${aws_elb.nginx.name}"]
  launch_configuration = "${aws_launch_configuration.nginx.name}"

  tag {
    key = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key = "server-role"
    value = "nginx"
    propagate_at_launch = true
  }

  tag {
    key = "env"
    value = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "nginx" {
  name_prefix = "${var.name}-"
  image_id = "${data.aws_ami.nginx_ami.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.nginx_profile}"
  security_groups = [
    "${aws_security_group.nginx_instance.id}"
  ]

  key_name = "${var.ssh_key_name}"

  user_data = <<<END
#!/bin/bash
cd /home/ubuntu/provisioning && ansible-playbook -c local -i localhost, nginx_playbook.yml -t instance-config \
    -e admin_user_ips=${var.admin_user_ips} \
    -e dev_user_ips=${var.dev_user_ips} \
    -e cloudwatch_log_group=${var.log_group_name} \
    -e cloudwatch_json_log_group=${var.json_log_group_name} \
    -e assets_subdomain=${var.assets_subdomain} \
    -e g7_draft_documents_s3_url=${var.g7_draft_documents_s3_url} \
    -e documents_s3_url=${var.documents_s3_url} \
    -e agreements_s3_url=${var.agreements_s3_url} \
    -e communications_s3_url=${var.communications_s3_url} \
    -e submissions_s3_url=${var.submissions_s3_url} \
    -e api_subdomain=${var.api_subdomain} \
    -e api_url=${var.api_url} \
    -e search_api_subdomain=${var.search_api_subdomain} \
    -e search_api_url=${var.search_api_url} \
    -e www_subdomain=${var.www_subdomain} \
    -e buyer_frontend_url=${var.buyer_frontend_url} \
    -e admin_frontend_url=${var.admin_frontend_url} \
    -e supplier_frontend_url=${var.supplier_frontend_url} \
    -e aws_region=${data.aws_region.current} \
    -e nameserver_ip=$(awk '/nameserver/{ print $2; exit}' /etc/resolv.conf)
END

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "nginx_role" {
  name = "${var.name}"
  path = "/"
  assume_role_policy = <<ENDPOLICY
{
  "Version" : "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ],
    "Resource": [
      "arn:aws:logs:eu-west-1:*:*"
    ]
  }]
}
ENDPOLICY
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${var.name}"
  roles = ["${aws_iam_role.nginx_role}"]
}

resource "aws_security_group" "nginx_instance" {
  name = "${var.name}"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_security_group_rule" "allow_http_from_elb" {
  security_group_id = "${aws_security_group.nginx_instance.id}"
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.nginx_elb.id}"
}
