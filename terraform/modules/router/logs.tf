resource "aws_cloudwatch_log_group" "json_logs" {
  name = "${var.name}-nginx"
  retention_in_days = "${var.log_retention_days}"
}
