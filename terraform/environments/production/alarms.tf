module "alarm_email_sns" {
  source     = "../../modules/logging/alarms/email-notification"
  name       = "production"
  account_id = var.aws_prod_account_id
}

module "alarm_recovery_email_sns" {
  source     = "../../modules/logging/alarms/email-notification"
  name       = "production-recovery"
  account_id = var.aws_prod_account_id
}

// Missing logs for the production-<app-name>-application log group metrics
module "missing_application_logs_alarms" {
  source                         = "../../modules/logging/alarms/missing-logs"
  environment                    = "production"
  type                           = "application"
  app_names                      = module.application_logs.app_names
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

// Missing logs for the production-router-nginx log group metrics
module "missing_nginx_logs_alarms" {
  source                         = "../../modules/logging/alarms/missing-logs"
  environment                    = "production"
  type                           = "nginx"
  app_names                      = ["router"]
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

module "slow_requests_alarms" {
  source                         = "../../modules/logging/alarms/slow-requests"
  environment                    = "production"
  app_name                       = "router"
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

module "router_500_alarm" {
  source                         = "../../modules/logging/alarms/status-code"
  environment                    = "production"
  status_code                    = "500"
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

module "router_429_alarm" {
  source                         = "../../modules/logging/alarms/status-code"
  environment                    = "production"
  status_code                    = "429"
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

module "reset_email_bad_role_alarm" {
  source                         = "../../modules/logging/alarms/reset-email-bad-role"
  environment                    = "production"
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

module "admin_manager_password_reset" {
  source                         = "../../modules/logging/alarms/admin-manager-password-reset"
  environment                    = "production"
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

module "dropped_av_sns_alarm" {
  source                         = "../../modules/logging/alarms/dropped-av-sns"
  environment                    = "production"
  alarm_email_topic_arn          = module.alarm_email_sns.email_topic_arn
  alarm_recovery_email_topic_arn = module.alarm_recovery_email_sns.email_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "log_stream_lambda_error_alarm" {
  alarm_name        = "production-log-stream-lambda"
  alarm_description = "Alarms on failure of production-log-stream-lambda lambda function."

  // Metric
  namespace   = "Lambda"
  metric_name = "Errors"

  dimensions = {
    LogGroupName = "production-log-stream-lambda"
    Resource     = "production-log-stream-lambda"
  }

  // For every 300 seconds
  evaluation_periods = "1"
  period             = "300"

  // If totals 1 or higher
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"

  // If there is no data then do not alarm
  treat_missing_data = "notBreaching"

  // Email slack
  alarm_actions = [module.alarm_email_sns.email_topic_arn]
  ok_actions = [module.alarm_recovery_email_sns.email_topic_arn]
}

