provider "aws" {
  region = "eu-west-1"
}

resource "aws_cloudwatch_log_group" "application_logs" {
  count             = length(var.app_names)
  name              = "${var.environment}-${element(var.app_names, count.index)}-application"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_group" "nginx_logs" {
  count             = length(var.app_names)
  name              = "${var.environment}-${element(var.app_names, count.index)}-nginx"
  retention_in_days = var.retention_in_days
}

