locals {
  api_env_vars = [
    { "name" : "DM_API_AUTH_TOKENS", "value" : "tokentokentoken" }, # TODO create and manage
    { "name" : "DM_APP_NAME", "value" : local.service_name_api },
    { "name" : "DM_ENVIRONMENT", "value" : var.environment_name },
    { "name" : "DM_LOG_PATH", "value" : "/dev/null" },
    { "name" : "PORT", "value" : "80" },
    { "name" : "VCAP_SERVICES", "value" : "{\"postgres\": [{\"name\": \"postgres\", \"credentials\": {\"uri\": \"TBC TODO\"}}]}" },
  ]
}

module "api_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region                      = var.aws_region
  aws_target_account              = var.aws_target_account
  container_environment_variables = local.api_env_vars
  desired_count                   = var.services_desired_counts[local.service_name_api]
  ecs_cluster_arn                 = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn          = aws_iam_role.execution_role.arn
  ecs_execution_role_name         = aws_iam_role.execution_role.name
  environment_name                = var.environment_name
  lb_target_group_arn             = aws_lb_target_group.api.arn
  project_name                    = var.project_name
  service_name                    = local.service_name_api
  service_subnet_ids              = module.dmp_vpc.private_subnet_ids
  target_group_security_group_id  = aws_security_group.api_lb_targets.id
  vpc_id                          = module.dmp_vpc.vpc_id
}
