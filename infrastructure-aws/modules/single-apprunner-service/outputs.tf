output "ecr_repo_url" {
  description = "URL of the ECR repo for the image which provides this service"
  value       = module.ecr_repo.repo_url
}

output "instance_role_arn" {
  description = "ARN of the service role created for AppRunner instances of this servuce"
  value       = aws_iam_role.instance_role.arn
}
