data "aws_acm_certificate" "nginx" {
  domain = "*.${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_elb" "nginx" {
  name = "${var.name}"

  subnets = ["${var.subnet_ids}"]
  security_groups = [
    "${aws_security_group.nginx_elb.id}"
  ]

  connection_draining = true
  connection_draining_timeout = 300

  listener {
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.nginx.arn}"
    instance_port = 80
    instance_protocol = "http"
  }

  health_check {
    target = "HTTP:80/_status"
    timeout = 5
    interval = 30
    healthy_threshold = 3
    unhealthy_threshold = 5
  }

  cross_zone_load_balancing = true
}

resource "aws_security_group" "nginx_elb" {
  name = "${var.name}-elb"
  vpc_id = "${var.vpc_id}"

  # HTTPS access
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-elb"
  }
}

resource "aws_security_group_rule" "allow_http_from_elb" {
  security_group_id = "${aws_security_group.nginx_elb.id}"
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.nginx_instance.id}"
}
