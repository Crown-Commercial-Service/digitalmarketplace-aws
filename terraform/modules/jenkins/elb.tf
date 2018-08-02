resource "aws_elb" "jenkins_elb" {
  name            = "Jenkins-ELB"
  subnets         = ["${aws_instance.jenkins3.subnet_id}"]
  instances       = ["${aws_instance.jenkins3.id}"]
  security_groups = ["${aws_security_group.jenkins_elb_security_group.id}"]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate.jenkins_elb_certificate.arn}"
  }

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:22"
    interval            = 30
  }

  tags {
    Name = "Jenkins ELB"
  }
}

resource "aws_acm_certificate" "jenkins_elb_certificate" {
  domain_name       = "ci3.marketplace.team"
  validation_method = "DNS"

  tags {
    Name = "Jenkins ELB certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "marketplace_team" {
  name         = "marketplace.team"
  private_zone = false
}

resource "aws_route53_record" "jenkins_elb_cert_validation" {
  name    = "${aws_acm_certificate.jenkins_elb_certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.jenkins_elb_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.marketplace_team.id}"
  records = ["${aws_acm_certificate.jenkins_elb_certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "jenkins_elb_certificate" {
  certificate_arn         = "${aws_acm_certificate.jenkins_elb_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.jenkins_elb_cert_validation.fqdn}"]
}
