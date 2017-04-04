output "instance_security_group_id" {
  value = "${aws_security_group.nginx_instance.id}"
}
