output "ecr_repo_url" {
  description = "URL of the ECR repo for the image which provides this service"
  value       = module.ecr_repo.repo_url
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.service.id
}

output "pass_task_role_policy_arn" {
  description = "ARN of policy permitting passage of the task role"
  value       = aws_iam_policy.pass_task_role.arn
}
