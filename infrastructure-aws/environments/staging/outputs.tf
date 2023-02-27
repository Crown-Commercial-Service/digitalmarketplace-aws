output "add_users_upload_bucket_id" {
  description = "Full name of the bucket to which new user creation files should be uploaded"
  value       = module.digitalmarketplace_full.add_users_upload_bucket_id
}

output "db_access_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the DB"
  value       = module.digitalmarketplace_full.db_access_security_group_id
}

output "db_migration_ecs_task_definition_arn" {
  description = "ARN of the task definition which provides the DB migration task"
  value       = module.digitalmarketplace_full.db_migration_ecs_task_definition_arn
}

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

output "egress_all_security_group_id" {
  description = "ID fo security group which allows all egress"
  value       = module.digitalmarketplace_full.egress_all_security_group_id
}

output "private_subnet_ids" {
  description = "List of IDs of each of the private subnets"
  value       = module.digitalmarketplace_full.private_subnet_ids
}
