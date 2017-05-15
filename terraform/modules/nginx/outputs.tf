output "instance_security_group_id" {
  value = "${aws_security_group.nginx_instance.id}"
}

output "json_log_groups" {
  value = ["${module.json_logs.log_group_name}"]
}
