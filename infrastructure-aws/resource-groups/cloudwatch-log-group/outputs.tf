output "log_group_name" {
  description = "Name of the log group"
  value       = aws_cloudwatch_log_group.log_group.name
}

output "write_log_group_policy_document_json" {
  description = "JSON describing an IAM policy which allows this log group to be written to"
  value       = data.aws_iam_policy_document.write_log_group.json
}
