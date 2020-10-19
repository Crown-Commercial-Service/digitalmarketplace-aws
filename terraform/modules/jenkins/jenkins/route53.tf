resource "aws_route53_record" "jenkins_a_record" {
  zone_id = var.dns_zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_elb.jenkins_elb.dns_name
    zone_id                = aws_elb.jenkins_elb.zone_id
    evaluate_target_health = true
  }
}

