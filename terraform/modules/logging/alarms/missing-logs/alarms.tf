// It's worth noting here that this alarm can never be triggered by the statistic comparison.
// AWS doesn't record a metric if the value is 0
// The alarm will be triggered when the metric is not emitted due to the breaching poicy on missing data

resource "aws_cloudwatch_metric_alarm" "missing_logs_alarm" {
  count             = "${length(var.app_names)}"
  alarm_name        = "${var.environment}-missing-logs-${var.app_names[count.index]}"
  alarm_description = "Alerts on missing logs from ${var.environment} ${var.app_names[count.index]}"

  // Metric
  namespace   = "AWS/Logs"
  metric_name = "IncomingLogEvents"

  dimensions {
    LogGroupName = "${var.environment}-${var.app_names[count.index]}-${var.type}"
  }

  // For 5 minutes
  // This appears to cause our alarms to trigger at around the 10-12 minute mark
  evaluation_periods = "5"

  period = "60"

  // Totals 0
  statistic           = "Sum"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "0"

  // Or if this metric is not emitted
  treat_missing_data = "breaching"

  // Email slack on error and recovery
  alarm_actions = ["${var.alarm_email_topic_arn}"]
  ok_actions    = ["${var.alarm_recovery_email_topic_arn}"]
}
