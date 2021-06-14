resource "aws_cloudwatch_metric_alarm" "slow_requests_gt_10_alarm" {
  alarm_name        = "${var.environment}-router-slow-requests-gt10s"
  alarm_description = "Alerts on 5 or more requests over 10 seconds in the last minute"

  // Metric
  namespace   = "DM-RequestTimeBuckets"
  metric_name = "${var.environment}-router-request-times-9"

  // For every 5 minutes
  evaluation_periods = "1"
  period             = "300"

  // If totals 1 or higher
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "5"

  // If there is no data then do not alarm
  treat_missing_data = "notBreaching"

  // Email slack
  alarm_actions = [var.alarm_email_topic_arn]
  ok_actions    = [var.alarm_recovery_email_topic_arn]
}
