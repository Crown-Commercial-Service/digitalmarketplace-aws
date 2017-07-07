output "application_log_groups" {
  value = ["${aws_cloudwatch_log_group.application_logs.*.name}"]
}

output "nginx_log_groups" {
  value = ["${aws_cloudwatch_log_group.nginx_logs.*.name}"]
}

output "app_names" {
  value = ["${var.app_names}"]
}
