resource "aws_cloudwatch_metric_alarm" "status_code_alarm" {
  alarm_name        = "${var.environment}-${var.status_code}s"
  alarm_description = "Alerts on ${var.status_code} on the ${var.environment} router."

  // Metric
  namespace   = "DM-${var.status_code}s"
  metric_name = "${var.environment}-router-nginx-${var.status_code}s"

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
