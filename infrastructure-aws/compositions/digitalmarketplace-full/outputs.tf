output "ecr_repos_urls" {
  description = "URLs of the ECR repos for the images which provide these service"
  value = {
    "buyer-frontend" : module.buyer_frontend_service.ecr_repo_url
  }
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.dmp.arn
}

output "ecs_services_arns" {
  description = "ARNs for each of the ECS services"
  value = {
    "buyer-frontend" : module.buyer_frontend_service.ecs_service_arn
  }
}
