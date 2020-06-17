module "alarm_email_sns" {
  source     = "../../modules/logging/alarms/email-notification"
  name       = "main"
  account_id = "${var.aws_main_account_id}"
}

module "alarm_recovery_email_sns" {
  source     = "../../modules/logging/alarms/email-notification"
  name       = "main-recovery"
  account_id = "${var.aws_main_account_id}"
}

resource "aws_cloudwatch_metric_alarm" "jenkins_data_volume_disk_space" {
  alarm_name        = "jenkins-data-volume-disk-space"
  alarm_description = "Alerts on disk space on 100gb /data volume"

  // Metric
  namespace   = "CWAgent"
  metric_name = "disk_free"

  dimensions = {
    path = "/data"
  }

  // For every 300 seconds
  evaluation_periods = "1"
  period             = "300"

  // If totals 10gb or lower (in bytes)
  statistic           = "Sum"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "10000000000"

  // Email slack
  alarm_actions = ["${module.alarm_email_sns.email_topic_arn}"]
  ok_actions    = ["${module.alarm_recovery_email_sns.email_topic_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "jenkins_main_volume_disk_space" {
  alarm_name        = "jenkins-main-volume-disk-space"
  alarm_description = "Alerts on disk space on 8gb / volume"

  // Metric
  namespace   = "CWAgent"
  metric_name = "disk_free"

  dimensions = {
    path = "/"
  }

  // For every 300 seconds
  evaluation_periods = "1"
  period             = "300"

  // If totals 1gb or lower (in bytes)
  statistic           = "Sum"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "1000000000"

  // Email slack
  alarm_actions = ["${module.alarm_email_sns.email_topic_arn}"]
  ok_actions    = ["${module.alarm_recovery_email_sns.email_topic_arn}"]
}
