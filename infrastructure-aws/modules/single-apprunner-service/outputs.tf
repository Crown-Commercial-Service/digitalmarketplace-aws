output "ecr_repo_url" {
  description = "URL of the ECR repo for the image which provides this service"
  value       = module.ecr_repo.repo_url
}
