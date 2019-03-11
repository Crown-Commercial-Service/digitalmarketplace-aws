output "cloud_watch_logs_group_arn" {
  value = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}"
}

output "cloud_watch_logs_role_arn" {
  value = "${aws_iam_role.cloudtrail_to_cloudwatch_role.arn}"
}
