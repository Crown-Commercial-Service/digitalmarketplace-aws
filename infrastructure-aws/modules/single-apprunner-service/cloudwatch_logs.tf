module "application_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-${var.service_name}-application"
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "instance_role__write_application_logs" {
  role       = aws_iam_role.instance_role.name
  policy_arn = module.application_log_group.write_log_group_policy_arn
}

module "nginx_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = "${var.environment_name}-${var.service_name}-nginx"
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "instance_role__write_nginx_logs" {
  role       = aws_iam_role.instance_role.name
  policy_arn = module.nginx_log_group.write_log_group_policy_arn
}
