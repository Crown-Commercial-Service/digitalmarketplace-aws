module "application_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-${var.service_name}-application"
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "task_role__write_application_logs" {
  role       = module.service_task_definition.task_role_name
  policy_arn = module.application_log_group.write_log_group_policy_arn
}

module "container_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-${var.service_name}-container"
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "ecs_execute__write_container_logs" {
  role       = var.ecs_execution_role_name
  policy_arn = module.container_log_group.write_log_group_policy_arn
}

module "nginx_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-${var.service_name}-nginx"
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "task_role__write_nginx_logs" {
  role       = module.service_task_definition.task_role_name
  policy_arn = module.nginx_log_group.write_log_group_policy_arn
}
