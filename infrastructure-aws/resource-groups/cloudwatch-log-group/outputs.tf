output "log_group_name" {
  description = "Name of the log group"
  value       = aws_cloudwatch_log_group.log_group.name
}

output "write_log_group_policy_arn" {
  description = "ARN of the IAM policy which allows this log group to be written to"
  value       = aws_iam_policy.write_log_group.arn
}
