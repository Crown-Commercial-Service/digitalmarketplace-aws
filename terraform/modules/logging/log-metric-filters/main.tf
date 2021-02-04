# App-specific nginx log buckets

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.70"
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_0" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-0"

  pattern        = "{$.requestTime >= 0 && $.requestTime < 0.025 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-0"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_1" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-1"

  pattern        = "{$.requestTime >= 0.025 && $.requestTime < 0.05 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-1"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_2" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-2"

  pattern        = "{$.requestTime >= 0.05 && $.requestTime < 0.1 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-2"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_3" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-3"

  pattern        = "{$.requestTime >= 0.1 && $.requestTime < 0.25 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-3"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_4" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-4"

  pattern        = "{$.requestTime >= 0.25 && $.requestTime < 0.5 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-4"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_5" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-5"

  pattern        = "{$.requestTime >= 0.5 && $.requestTime < 1 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-5"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_6" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-6"

  pattern        = "{$.requestTime >= 1  && $.requestTime < 2.5 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-6"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_7" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-7"

  pattern        = "{$.requestTime >= 2.5  && $.requestTime < 5 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-7"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_8" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-8"

  pattern        = "{$.requestTime >= 5  && $.requestTime < 10 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-8"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_9" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-9"

  pattern        = "{$.requestTime >= 10 && $.request != \"*/_status?ignore-dependencies *\" && $.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-request-times-9"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "application-500s" {
  count          = length(var.app_names)
  name           = "${var.environment}-${element(var.app_names, count.index)}-500s"
  pattern        = "{$.status = 5*}"
  log_group_name = "${var.environment}-${element(var.app_names, count.index)}-nginx"

  metric_transformation {
    name          = "${var.environment}-${element(var.app_names, count.index)}-nginx-500s"
    namespace     = "DM-500s"
    value         = "1"
    default_value = "0"
  }
}

# Main nginx log buckets

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_0" {
  name           = "${var.environment}-router-request-times-0"
  pattern        = "{$.requestTime >= 0 && $.requestTime < 0.025 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-0"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_1" {
  name           = "${var.environment}-router-request-times-1"
  pattern        = "{$.requestTime >= 0.025 && $.requestTime < 0.05 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-1"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_2" {
  name           = "${var.environment}-router-request-times-2"
  pattern        = "{$.requestTime >= 0.05 && $.requestTime < 0.1 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-2"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_3" {
  name           = "${var.environment}-router-request-times-3"
  pattern        = "{$.requestTime >= 0.1 && $.requestTime < 0.25 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-3"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_4" {
  name           = "${var.environment}-router-request-times-4"
  pattern        = "{$.requestTime >= 0.25 && $.requestTime < 0.5 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-4"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_5" {
  name           = "${var.environment}-router-request-times-5"
  pattern        = "{$.requestTime >= 0.5 && $.requestTime < 1 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-5"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_6" {
  name           = "${var.environment}-router-request-times-6"
  pattern        = "{$.requestTime >= 1 && $.requestTime < 2.5 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-6"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_7" {
  name           = "${var.environment}-router-request-times-7"
  pattern        = "{$.requestTime >= 2.5 && $.requestTime < 5 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-7"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_8" {
  name           = "${var.environment}-router-request-times-8"
  pattern        = "{($.request != \"POST*\" || $.requestSize < 50000) && $.requestTime >= 5 && $.requestTime < 10 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-8"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_9" {
  name           = "${var.environment}-router-request-times-9"
  pattern        = "{($.request != \"POST*\" || $.requestSize < 50000) && $.requestTime >= 10 && $.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-request-times-9"
    namespace     = "DM-RequestTimeBuckets"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "router-500s" {
  name           = "${var.environment}-router-500s"
  pattern        = "{$.status = 5*}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-nginx-500s"
    namespace     = "DM-500s"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "router-429s" {
  name           = "${var.environment}-router-429s"
  pattern        = "{$.status = 429}"
  log_group_name = var.router_log_group_name

  metric_transformation {
    name          = "${var.environment}-router-nginx-429s"
    namespace     = "DM-429s"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "reset-email-bad-role" {
  name           = "${var.environment}-reset-email-bad-role"
  pattern        = "{$.code = \"login.reset-email.bad-role\"}"
  log_group_name = "${var.environment}-user-frontend-application"

  metric_transformation {
    name          = "${var.environment}-reset-email-bad-role"
    namespace     = "DM-reset-email-bad-role"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "admin-manager-password-reset" {
  name           = "${var.environment}-reset-email-bad-role"
  pattern        = "{$.code = \"update_user.password.role_warning\"}"
  log_group_name = "${var.environment}-api-application"

  metric_transformation {
    name          = "${var.environment}-admin-manager-password-reset"
    namespace     = "DM-admin-manager-password-reset"
    value         = "1"
    default_value = "0"
  }
}

# The following two log metric filters output to the same metric (${var.environment}-dropped-antivirus-sns):
# Because we have separate log streams 'Failure to connect to the AV API' and 'The AV API successfully returned a response'
# we have to filter the "success" log group for responses >= 400 and the "failure" log group for anything

resource "aws_cloudwatch_log_metric_filter" "dropped-antivirus-sns-final-retry" {
  name           = "${var.environment}-dropped-antivirus-sns-final-retry"
  pattern        = "{$.delivery.attempts = ${var.antivirus_sns_topic_num_retries} }"
  log_group_name = var.antivirus_sns_failure_log_group_name

  metric_transformation {
    name          = "${var.environment}-dropped-antivirus-sns"
    namespace     = "DM-SNS"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "dropped-antivirus-sns-4xx" {
  name           = "${var.environment}-dropped-antivirus-sns-4xx"
  pattern        = "{$.delivery.statusCode >= 400}"
  log_group_name = var.antivirus_sns_success_log_group_name

  metric_transformation {
    name          = "${var.environment}-dropped-antivirus-sns"
    namespace     = "DM-SNS"
    value         = "1"
    default_value = "0"
  }
}

# App specific metrics for apiclient retries

resource "aws_cloudwatch_log_metric_filter" "apiclient-retries" {
  count = length(var.app_names)
  name  = "${var.environment}-${var.app_names[count.index]}-apiclient-retries"

  pattern        = "{$.name = urllib3.util.retry}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-application"

  metric_transformation {
    name          = "${var.environment}-${var.app_names[count.index]}-apiclient-retries"
    namespace     = "DM-APIClient-Retries"
    value         = "1"
    default_value = "0"
  }
}

