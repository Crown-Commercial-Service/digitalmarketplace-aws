output "log_groups" {
  value = ["${concat(aws_cloudwatch_log_group.application_logs.*.name, aws_cloudwatch_log_group.nginx_logs.*.name)}"]
}
