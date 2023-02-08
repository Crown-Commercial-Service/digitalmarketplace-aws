output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = aws_iam_role.apprunner_build.arn
}

output "instance_role_buyer_frontend_arn" {
  description = "ARN of the service role created for AppRunner instances of the Buyer Frontend servuce"
  value       = module.buyer_frontend_service.instance_role_arn
}

output "ecr_repo_url_buyer_frontend" {
  description = "URL of the ECR repo for Buyer Frontend"
  value       = module.buyer_frontend_service.ecr_repo_url
}
