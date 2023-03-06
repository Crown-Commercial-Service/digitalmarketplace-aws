/* See `service_buyer_frontend.tf` for notes on the more spurious env vars at work here.
*/
locals {
  user_frontend_env_vars = [
    { "name" : "DM_APP_NAME", "value" : local.service_name_user_frontend },
    { "name" : "DM_DATA_API_URL", "value" : "http://${aws_lb.api.dns_name}" },
    { "name" : "DM_ENVIRONMENT", "value" : var.environment_name },
    { "name" : "DM_LOG_PATH", "value" : "/dev/null" },
    { "name" : "DM_REDIS_SERVICE_NAME", "value" : "redis" },
    { "name" : "PORT", "value" : "80" },
    { "name" : "PROXY_AUTH_CREDENTIALS", "value" : local.proxy_credentials_htpasswd_string },
    { "name" : "VCAP_SERVICES", "value" : "{\"redis\": [{\"name\": \"redis\", \"credentials\": {\"uri\": \"redis://${local.redis_uri}\"}}]}" }
  ]
}

module "user_frontend_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region                      = var.aws_region
  aws_target_account              = var.aws_target_account
  container_healthcheck_command   = "curl -f -u ${local.proxy_credentials} http://localhost/user/login || exit 1"
  container_memory                = var.services_container_memories[local.service_name_user_frontend]
  desired_count                   = var.services_desired_counts[local.service_name_user_frontend]
  container_environment_variables = local.user_frontend_env_vars
  ecs_cluster_arn                 = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn          = aws_iam_role.ecs_execution_role.arn
  environment_name                = var.environment_name
  lb_target_group_arn             = aws_lb_target_group.user_frontend.arn
  project_name                    = var.project_name
  secret_environment_variables = [
    { "name" : "DM_DATA_API_AUTH_TOKEN", "valueFrom" : aws_secretsmanager_secret.data_api_token.arn },
    { "name" : "SECRET_KEY", "valueFrom" : aws_secretsmanager_secret.fe_secret_key.arn }
  ]
  security_group_ids = [
    aws_security_group.api_clients.id,
    aws_security_group.egress_all.id,
    aws_security_group.frontend_lb_targets.id
  ]
  service_name       = local.service_name_user_frontend
  service_subnet_ids = module.dmp_vpc.private_subnet_ids
  vpc_id             = module.dmp_vpc.vpc_id
}

resource "aws_lb_target_group" "user_frontend" {
  name            = "${var.environment_name}-user-frontend"
  ip_address_type = "ipv4"
  port            = "80"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = module.dmp_vpc.vpc_id

  health_check {
    matcher  = "200,401" # 401 is healthy
    path     = "/"
    port     = "80"
    protocol = "HTTP"
  }
}
