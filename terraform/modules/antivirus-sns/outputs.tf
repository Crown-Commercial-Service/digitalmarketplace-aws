output "failure_log_group_name" {
  value = "${aws_cloudwatch_log_group.antivirus_sns_logs_failure.name}"
}

output "success_log_group_name" {
  value = "${aws_cloudwatch_log_group.antivirus_sns_logs_success.name}"
}

output "topic_num_retries" {
  value = "${var.topic_num_retries}"
}
