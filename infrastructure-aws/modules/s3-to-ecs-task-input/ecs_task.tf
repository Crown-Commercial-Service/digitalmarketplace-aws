module "task_definition" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_region                      = var.aws_region
  aws_target_account              = var.aws_target_account
  container_environment_variables = var.container_environment_variables
  container_log_group_name        = module.task_log_group.log_group_name
  container_memory                = var.container_memory
  container_name                  = var.process_name
  ecr_repo_url                    = var.ecr_repo_url
  ecs_execution_role_arn          = var.ecs_execution_role_arn
  efs_mount_config = {
    access_point_id = aws_efs_access_point.access.id
    file_system_id  = aws_efs_file_system.filesystem.id
    mount_point     = local.fs_local_mount_path
    volume_name     = "efs0"
  }
  family_name                  = "${var.project_name}-${var.environment_name}-${var.process_name}"
  secret_environment_variables = var.secret_environment_variables
}

module "task_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-${var.process_name}"
  project_name   = var.project_name
}

resource "aws_iam_policy" "write_logs" {
  name   = "${var.project_name}-${var.environment_name}-${var.process_name}-logs-write"
  policy = module.task_log_group.write_log_group_policy_document_json
}

resource "aws_iam_role_policy_attachment" "task_role__write_logs" {
  role       = module.task_definition.task_role_name
  policy_arn = aws_iam_policy.write_logs.arn
}
