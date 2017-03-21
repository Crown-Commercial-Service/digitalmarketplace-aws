data "aws_region" "current" {
  current = true
}

data "aws_ami" "elasticsearch_ami" {
  owners = ["${var.ami_owner_account_id}"]
  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "tag:server-role"
    values = ["elasticsearch"]
  }
  most_recent = true
}

resource "aws_autoscaling_group" "elasticsearch_autoscaling_group" {
  name = "${var.name}"

  min_size = "${var.min_instance_count}"
  max_size = "${var.max_instance_count}"
  desired_capicity = "${var.instance_count}"

  health_check_type = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = ["${var.subnet_ids}"]

  load_balancers = ["${aws_elb.elasticsearch_elb.name}"]
  launch_configuration = "${aws_launch_configuration.elasticsearch.name}"

  tag {
    key = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key = "Group"
    value = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key = "server-role"
    value = "elasticsearch"
    propagate_at_launch = true
  }

  tag {
    key = "env"
    value = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "elasticsearch" {
  name_prefix = "${var.name}-"
  image_id = "${data.aws_ami.elasticsearch_ami.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.elasticsearch_profile}"
  security_groups = [
    "${aws_security_group.elasticsearch_instance.id}"
  ]

  key_name = "${var.ssh_key_name}"

  user_data = <<<END
#!/bin/bash
cd /home/ubuntu/provisioning && ansible-playbook -c local -i localhost, elasticsearch_playbook.yml -t instance-config \
    -e cloudwatch_log_group=${var.log_group_name} \
    -e elasticsearch_name=${var.name} \
    -e aws_region=${data.aws_region.current}
END

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "elasticsearch" {
  name = "${var.name}"
  path = "/"

resource "aws_iam_instance_profile" "elasticsearch_profile" {
  name = "${var.name}"
  roles = ["${aws_iam_role.elasticsearch}"]
}

resource "aws_iam_policy" "elasticsearch_discovery" {
  name = "${var.name}-discovery"
  path = "/"

  policy = <<ENDPOLICY
{
  "Version" : "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "ec2:DescribeInstances",
    "Resource": "*"
  }]
}
ENDPOLICY
}

resource "aws_iam_policy_attachment" "elasticsearch_discovery" {
  name = "${aws_iam_policy.elasticsearch_discovery.name}-attachment"
  policy_arn = "${aws_iam_policy.elasticsearch_discovery.arn}"
  roles = ["${aws_iam_role.elasticsearch.name}"]
}

resource "aws_security_group" "elasticsearch_instance" {
  name = "${var.name}"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_security_group_rule" "allow_http_from_elb" {
  security_group_id = "${aws_security_group.nginx_instance.id}"
  type = "ingress"
  from_port = "${var.elasticsearch_port}"
  to_port = "${var.elasticsearch_port}"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.elasticsearch_elb.id}"
}
