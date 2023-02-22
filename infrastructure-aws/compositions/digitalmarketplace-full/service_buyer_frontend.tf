/* Notes on the hardcoded env vars below.
   During this POC we have an enforced rules that we cannot alter the source application code. The Concept under
   Proof is that we can re-house unchanged code.

   Setting DM_LOG_PATH to /dev/null is a hack for the POC. The rationale goes like this:
     1. For reasons documented elsewhere it is necessary to run the frotnend services in this
        POC in an "as-Live" mode (in our case we choose 'staging')
     2. During existing operations, in "as-live" mode, DM_LOG_PATH is usually set to blank by
        providing it as an empty environment variable (i.e. `DM_LOG_PATH=`)
     3. Leaving DM_LOG_PATH as the default value '/var/log/digitalmarketplace/application.log' surfaces
        what appears to be an undetected bug in the service: the directory /var/log/digitalmarketplace is
        writable only by the root user whereas the Flask app which attempts to write this log runs as a
        non-root user. Therefore the service fails to start up.

    And so we are forced to pass in a DM_LOG_PATH value which has the following qualities:
        - is non-blank
        - doesn't name a file location which is out of permission
        - doesn't write to an unrotated / non-housekepy location and fill up the container volume

    Hence /dev/null.
*/
locals {
  buyer_frontend_env_vars = [
    { "name" : "DM_APP_NAME", "value" : local.service_name_buyer_frontend },
    { "name" : "DM_DATA_API_URL", "value" : aws_lambda_function_url.fake_api.function_url }, # TODO - Now use the API LB dns_name
    { "name" : "DM_ENVIRONMENT", "value" : var.environment_name },
    { "name" : "DM_LOG_PATH", "value" : "/dev/null" },
    { "name" : "DM_REDIS_SERVICE_NAME", "value" : "redis" },
    { "name" : "PORT", "value" : "80" },
    # Temporary hack for the POC before we have a routing service in front of the "frontend" apps - TODO Not for prod!
    { "name" : "PROXY_AUTH_CREDENTIALS", "value" : "poc:$apr1$ucZGAcrR$AZlxfQzm2vrYJT/HYwBWF/" },
    { "name" : "VCAP_SERVICES", "value" : "{\"redis\": [{\"name\": \"redis\", \"credentials\": {\"uri\": \"redis://${local.redis_uri}\"}}]}" }
  ]
}

module "buyer_frontend_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region                      = var.aws_region
  aws_target_account              = var.aws_target_account
  desired_count                   = var.services_desired_counts[local.service_name_buyer_frontend]
  container_environment_variables = local.buyer_frontend_env_vars
  ecs_cluster_arn                 = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn          = aws_iam_role.execution_role.arn
  ecs_execution_role_name         = aws_iam_role.execution_role.name
  egress_all_security_group_id    = aws_security_group.egress_all.id
  environment_name                = var.environment_name
  lb_target_group_arn             = aws_lb_target_group.buyer_frontend.arn
  project_name                    = var.project_name
  service_name                    = local.service_name_buyer_frontend
  service_subnet_ids              = module.dmp_vpc.private_subnet_ids
  target_group_security_group_id  = aws_security_group.frontend_lb_targets.id
  vpc_id                          = module.dmp_vpc.vpc_id
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
