resource "aws_cloudwatch_metric_alarm" "admin_manager_password_reset" {
  alarm_name        = "${var.environment}-admin-manager-password-reset"
  alarm_description = "Resetting the password for an admin manager role should notify Slack."

  // Metric
  namespace   = "DM-admin-manager-password-reset"
  metric_name = "${var.environment}-admin-manager-password-reset"

  // For for every 60 seconds
  evaluation_periods = "1"
  period             = "60"

  // If totals 1 or higher
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"

  // If there is no data then do not alarm
  treat_missing_data = "notBreaching"

  // Email slack
  alarm_actions = ["${var.alarm_email_topic_arn}"]
  ok_actions    = ["${var.alarm_recovery_email_topic_arn}"]
}
