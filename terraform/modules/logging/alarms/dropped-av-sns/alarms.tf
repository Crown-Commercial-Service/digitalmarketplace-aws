resource "aws_cloudwatch_metric_alarm" "dropped_antivirus_sns_alarm" {
  alarm_name        = "${var.environment}-dropped-antivirus-sns"
  alarm_description = "Alarms on failure to inform the ${var.environment} AV API that a file has uploaded and needs to be scanned."

  // Metric
  namespace   = "DM-SNS"
  metric_name = "${var.environment}-dropped-antivirus-sns"

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
