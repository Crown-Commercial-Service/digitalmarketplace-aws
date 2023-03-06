output "ecr_repo_url" {
  description = "URL of the ECR repo for the image which provides this service"
  value       = module.ecr_repo.repo_url
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.service.id
}

output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the task role"
  value       = module.service_task_definition.pass_task_role_policy_document_json
}

output "read_ecr_repo_policy_document_json" {
  description = "JSON describing an IAM policy which allows read access to the ECR repo for this ECS service"
  value       = module.ecr_repo.read_repo_policy_document_json
}

output "write_container_logs_policy_document_json" {
  description = "JSON describing an IAM policy which allows the container logs to be written to"
  value       = module.container_log_group.write_log_group_policy_document_json
}
