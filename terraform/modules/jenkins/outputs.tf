output "jenkins_2_elastic_ip" {
  value = "${aws_eip.jenkins2.public_ip}"
}
