output "jenkins_3_elastic_ip" {
  value = "${aws_eip.jenkins3.public_ip}"
}
