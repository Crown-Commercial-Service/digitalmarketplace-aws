module "email_alarm_sns" {
  source      = "../../modules/logging/alarms/email-notification"
  environment = "preview"
  account_id  = "${var.aws_dev_account_id}"
}

// Missing logs for the preview-<app-name>-application log group metrics
module "missing_application_logs_alarms" {
  source                = "../../modules/logging/alarms/missing-logs"
  environment           = "preview"
  type                  = "application"
  app_names             = ["${module.application_logs.app_names}"]
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
}

// Missing logs for the preview-router-nginx log group metrics
module "missing_nginx_logs_alarms" {
  source                = "../../modules/logging/alarms/missing-logs"
  environment           = "preview"
  type                  = "nginx"
  app_names             = ["router"]
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
}

module "slow_requests_alarms" {
  source                = "../../modules/logging/alarms/slow-requests"
  environment           = "preview"
  app_name              = "router"
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
}

module "router_500_alarm" {
  source                = "../../modules/logging/alarms/status-code"
  environment           = "preview"
  status_code           = "500"
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
}

module "router_429_alarm" {
  source                = "../../modules/logging/alarms/status-code"
  environment           = "preview"
  status_code           = "429"
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
}
