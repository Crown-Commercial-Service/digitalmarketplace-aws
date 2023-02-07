output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = module.digitalmarketplace_full.apprunner_build_iam_role_arn
}

output "ecr_repo_url_buyer_frontend" {
  description = "URL of the ECR repo for Buyer Frontend"
  value       = module.digitalmarketplace_full.ecr_repo_url_buyer_frontend
}
