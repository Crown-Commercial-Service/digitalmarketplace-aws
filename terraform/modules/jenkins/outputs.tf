output "jenkins_elb_dns_name" {
  value = "${aws_elb.jenkins_elb.dns_name}"
}

output "jenkins_elb_zone_id" {
  value = "${aws_elb.jenkins_elb.zone_id}"
}
