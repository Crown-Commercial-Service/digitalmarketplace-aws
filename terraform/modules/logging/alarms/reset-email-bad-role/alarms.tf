resource "aws_cloudwatch_metric_alarm" "reset_email_bad_role_alarm" {
  alarm_name        = "${var.environment}-reset-email-bad-roles"
  alarm_description = "Attempts at resetting the password for a user role it has been disabled for on ${var.environment}."

  // Metric
  namespace   = "DM-reset-email-bad-role"
  metric_name = "${var.environment}-reset-email-bad-role"

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
