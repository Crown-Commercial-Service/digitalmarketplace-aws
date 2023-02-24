locals {
  api_env_vars = [
    { "name" : "DM_APP_NAME", "value" : local.service_name_api },
    { "name" : "DM_ENVIRONMENT", "value" : var.environment_name },
    { "name" : "DM_LOG_PATH", "value" : "/dev/null" },
    { "name" : "PORT", "value" : "80" },
  ]
}

module "api_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region                      = var.aws_region
  aws_target_account              = var.aws_target_account
  container_environment_variables = local.api_env_vars
  container_healthcheck_command   = "curl -f -H \"Authorization: Bearer ${random_password.data_api_token.result}\" http://localhost/frameworks || exit 1"
  container_memory                = var.services_container_memories[local.service_name_api]
  desired_count                   = var.services_desired_counts[local.service_name_api]
  ecs_cluster_arn                 = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn          = aws_iam_role.ecs_execution_role.arn
  ecs_execution_role_name         = aws_iam_role.ecs_execution_role.name
  environment_name                = var.environment_name
  lb_target_group_arn             = aws_lb_target_group.api.arn
  project_name                    = var.project_name
  secret_environment_variables = [
    { "name" : "DM_API_AUTH_TOKENS", "valueFrom" : aws_secretsmanager_secret.data_api_token.arn },
    { "name" : "VCAP_SERVICES", "valueFrom" : aws_secretsmanager_secret.db_creds_vcap.arn }
  ]
  security_group_ids = [
    aws_security_group.api_lb_targets.id,
    aws_security_group.egress_all.id,
    module.dmp_db.db_access_security_group_id
  ]
  service_name       = local.service_name_api
  service_subnet_ids = module.dmp_vpc.private_subnet_ids
  vpc_id             = module.dmp_vpc.vpc_id
}

resource "random_password" "data_api_token" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "data_api_token" {
  name        = "${var.project_name}-${var.environment_name}-data-api-token"
  description = "Auto-generated token for the Data API"
}

resource "aws_secretsmanager_secret_version" "data_api_token" {
  secret_id     = aws_secretsmanager_secret.data_api_token.id
  secret_string = random_password.data_api_token.result
}
