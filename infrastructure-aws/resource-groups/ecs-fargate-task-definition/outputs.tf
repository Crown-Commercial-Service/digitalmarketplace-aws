output "pass_task_role_policy_arn" {
  description = "ARN of policy permitting passage of the task role"
  value       = aws_iam_policy.pass_task_role.arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "task_role_name" {
  description = "Name of the IAM role assigned to all tasks run under this task definition"
  value       = aws_iam_role.task_role.name
}
