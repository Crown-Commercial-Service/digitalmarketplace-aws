module "buyer_frontend_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region                 = var.aws_region
  aws_target_account         = var.aws_target_account
  desired_count              = var.services_desired_counts[local.service_name_buyer_frontend]
  ecs_cluster_arn            = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn     = aws_iam_role.execution_role.arn
  ecs_execution_role_name    = aws_iam_role.execution_role.name
  fake_api_url               = aws_lambda_function_url.fake_api.function_url
  environment_name           = var.environment_name
  project_name               = var.project_name
  service_name               = local.service_name_buyer_frontend
  service_security_group_ids = [module.dmp_vpc.default_security_group_id]
  service_subnet_ids         = module.dmp_vpc.private_subnet_ids
  session_cache_nodes        = aws_elasticache_cluster.frontend_sessions.cache_nodes
  vpc_id                     = module.dmp_vpc.vpc_id
}
