resource "aws_cloudwatch_log_group" "application_logs" {
  count = 5
  name = "${var.environment}-${element(var.app_names, count.index)}-application"
  retention_in_days = "${var.retention_in_days}"
}

resource "aws_cloudwatch_log_group" "nginx_logs" {
  count = 5
  name = "${var.environment}-${element(var.app_names, count.index)}-nginx"
  retention_in_days = "${var.retention_in_days}"
}
