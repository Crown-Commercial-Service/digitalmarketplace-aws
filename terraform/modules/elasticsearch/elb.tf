resource "aws_elb" "elasticsearch_elb" {
  name = "{var.name}"
  internal = true

  subnets = ["${var.subnet_ids}"]
  security_groups = [
    "${aws_security_group.elasticsearch_elb.id}"
  ]

  connection_draining = true
  connection_draining_timeout = 300

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.elasticsearch_port}"
    instance_protocol = "http"
  }

  health_check {
    target = "HTTP:${var.elasticsearch_port}/"
    timeout = 5
    interval = 30
    healthy_threshold = 3
    unhealthy_threshold = 5
  }

  cross_zone_load_balancing = true
}

resource "aws_security_group" "elasticsearch_elb" {
  name = "${var.name}-elb"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.name}-elb"
  }
}

resource "aws_security_group_rule" "allow_http_from_nginx" {
  security_group_id = "${aws_security_group.elasticsearch_elb.id}"
  type = "ingress"
  from_port = "${var.elasticsearch_port}"
  to_port = "${var.elasticsearch_port}"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.nginx_instance.id}"
}
