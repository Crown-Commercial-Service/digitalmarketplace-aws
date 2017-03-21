resource "aws_elb" "nginx_elb" {
  name = "{var.name}"

  subnets = ["${var.subnet_ids}"]
  security_groups = [
    "${aws_security_group.nginx_elb.id}"
  ]

  connection_draining = true
  connection_draining_timeout = 300

  listener {
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.ssl_cert_arn}"
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
    cidr_blocks = ["${var.user_ips}"]
  }

  tags = {
    Name = "${var.name}-elb"
  }
}
