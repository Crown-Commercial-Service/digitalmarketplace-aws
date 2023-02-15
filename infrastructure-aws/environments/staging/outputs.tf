output "ecr_repos_urls" {
  description = "URLs of the ECR repos for the images which provide these service"
  value       = module.digitalmarketplace_full.ecr_repos_urls
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.digitalmarketplace_full.ecs_cluster_arn
}

output "ecs_services_arns" {
  description = "ARNs for each of the ECS services"
  value       = module.digitalmarketplace_full.ecs_services_arns
}
