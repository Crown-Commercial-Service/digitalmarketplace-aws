output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = module.digitalmarketplace_full.apprunner_build_iam_role_arn
}

output "ecr_repo_url_buyer_frontend" {
  description = "URL of the ECR repo for Buyer Frontend"
  value       = module.digitalmarketplace_full.ecr_repo_url_buyer_frontend
}

output "fake_api_url" {
  description = "Open access endpoint to the fake API"
  value       = module.digitalmarketplace_full.fake_api_url
}

output "instance_role_buyer_frontend_arn" {
  description = "ARN of the service role created for AppRunner instances of the Buyer Frontend servuce"
  value       = module.digitalmarketplace_full.instance_role_buyer_frontend_arn
}
