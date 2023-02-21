module "buyer_frontend_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region                     = var.aws_region
  aws_target_account             = var.aws_target_account
  desired_count                  = var.services_desired_counts[local.service_name_buyer_frontend]
  ecs_cluster_arn                = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn         = aws_iam_role.execution_role.arn
  ecs_execution_role_name        = aws_iam_role.execution_role.name
  environment_name               = var.environment_name
  fake_api_url                   = aws_lambda_function_url.fake_api.function_url
  lb_target_group_arn            = aws_lb_target_group.buyer_frontend.arn
  project_name                   = var.project_name
  service_name                   = local.service_name_buyer_frontend
  service_subnet_ids             = module.dmp_vpc.private_subnet_ids
  session_cache_nodes            = aws_elasticache_cluster.frontend_cache.cache_nodes
  target_group_security_group_id = aws_security_group.frontend_lb_targets.id
  vpc_id                         = module.dmp_vpc.vpc_id
}

resource "aws_lb_target_group" "buyer_frontend" {
  name            = "${var.environment_name}-buyer-frontend"
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
