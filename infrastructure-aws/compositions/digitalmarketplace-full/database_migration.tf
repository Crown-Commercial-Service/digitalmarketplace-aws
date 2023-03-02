module "db_migration_task_definition" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_region         = var.aws_region
  aws_target_account = var.aws_target_account
  container_environment_variables = [
    { "name" : "FLASK_APP", "value" : "application:application" }
  ]
  container_log_group_name = module.migration_log_group.log_group_name
  container_memory         = var.services_container_memories[local.service_name_api] # Use the API memory settings
  container_name           = "db-migration"
  ecr_repo_url             = module.api_service.ecr_repo_url # Migration uses the API codebase
  ecs_execution_role_arn   = aws_iam_role.ecs_execution_role.arn
  family_name              = "${var.project_name}-${var.environment_name}-db-migration"
  override_command = [
    "/app/venv/bin/flask", "db", "upgrade"
  ]
  secret_environment_variables = [
    { "name" : "VCAP_SERVICES", "valueFrom" : aws_secretsmanager_secret.db_creds_vcap.arn }
  ]
}

module "migration_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-db-migration"
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "db_migration_task__write_migration_logs" {
  role       = module.db_migration_task_definition.task_role_name
  policy_arn = module.migration_log_group.write_log_group_policy_arn
}

resource "aws_iam_role_policy_attachment" "execution_role__write_migration_logs" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = module.migration_log_group.write_log_group_policy_arn
}
