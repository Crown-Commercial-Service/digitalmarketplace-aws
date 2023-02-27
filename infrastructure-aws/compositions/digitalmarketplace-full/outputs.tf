output "add_users_upload_bucket_id" {
  description = "Full name of the bucket to which new user creation files should be uploaded"
  value       = module.dmp_add_users.upload_bucket_id
}

output "db_access_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the DB"
  value       = module.dmp_db.db_access_security_group_id
}

output "db_migration_ecs_task_definition_arn" {
  description = "ARN of the task definition which provides the DB migration task"
  value       = module.db_migration_task_definition.task_definition_arn
}

output "ecr_repos_urls" {
  description = "URLs of the ECR repos for the images which provide these service"
  value = {
    "api" : module.api_service.ecr_repo_url,
    "buyer-frontend" : module.buyer_frontend_service.ecr_repo_url,
    "user-front-end" : module.user_frontend_service.ecr_repo_url
  }
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.dmp.arn
}

output "ecs_services_arns" {
  description = "ARNs for each of the ECS services"
  value = {
    "api" : module.api_service.ecs_service_arn,
    "buyer-frontend" : module.buyer_frontend_service.ecs_service_arn,
    "user-front-end" : module.user_frontend_service.ecs_service_arn
  }
}

output "egress_all_security_group_id" {
  description = "ID fo security group which allows all egress"
  value       = aws_security_group.egress_all.id
}

output "private_subnet_ids" {
  description = "List of IDs of each of the private subnets"
  value       = module.dmp_vpc.private_subnet_ids
}
