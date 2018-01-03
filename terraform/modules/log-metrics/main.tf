# App-specific nginx log buckets

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_0" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-0"

  pattern        = "{$$.requestTime >= 0 && $$.requestTime < 0.025 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-0"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_1" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-1"

  pattern        = "{$$.requestTime >= 0.025 && $$.requestTime < 0.05 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-1"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_2" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-2"

  pattern        = "{$$.requestTime >= 0.05 && $$.requestTime < 0.1 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-2"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_3" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-3"

  pattern        = "{$$.requestTime >= 0.1 && $$.requestTime < 0.25 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-3"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_4" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-4"

  pattern        = "{$$.requestTime >= 0.25 && $$.requestTime < 0.5 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-4"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_5" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-5"

  pattern        = "{$$.requestTime >= 0.5 && $$.requestTime < 1 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-5"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_6" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-6"

  pattern        = "{$$.requestTime >= 1  && $$.requestTime < 2.5 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-6"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_7" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-7"

  pattern        = "{$$.requestTime >= 2.5  && $$.requestTime < 5 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-7"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_8" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-8"

  pattern        = "{$$.requestTime >= 5  && $$.requestTime < 10 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-8"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_9" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${var.app_names[count.index]}-request-times-9"

  pattern        = "{$$.requestTime >= 10 && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-${var.app_names[count.index]}-nginx"

  metric_transformation {
    name  = "${var.environment}-${var.app_names[count.index]}-request-times-9"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "application-500s" {
  count = "${length(var.app_names)}"
  name  = "${var.environment}-${element(var.app_names, count.index)}-500s"
  pattern        = "{$$.status = 5*}"
  log_group_name = "${var.environment}-${element(var.app_names, count.index)}-nginx"

  metric_transformation {
    name  = "${var.environment}-${element(var.app_names, count.index)}-nginx-500s"
    namespace = "DM-500s"
    value     = "1"
    default_value = "0"
  }
}

# Main nginx log buckets

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_0" {
  name  = "${var.environment}-router-request-times-0"
  pattern        = "{$$.requestTime >= 0 && $$.requestTime < 0.025 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-0"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_1" {
  name  = "${var.environment}-router-request-times-1"
  pattern        = "{$$.requestTime >= 0.025 && $$.requestTime < 0.05 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-1"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_2" {
  name  = "${var.environment}-router-request-times-2"
  pattern        = "{$$.requestTime >= 0.05 && $$.requestTime < 0.1 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-2"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_3" {
  name  = "${var.environment}-router-request-times-3"
  pattern        = "{$$.requestTime >= 0.1 && $$.requestTime < 0.25 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-3"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_4" {
  name  = "${var.environment}-router-request-times-4"
  pattern        = "{$$.requestTime >= 0.25 && $$.requestTime < 0.5 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-4"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_5" {
  name  = "${var.environment}-router-request-times-5"
  pattern        = "{$$.requestTime >= 0.5 && $$.requestTime < 1 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-5"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_6" {
  name  = "${var.environment}-router-request-times-6"
  pattern        = "{$$.requestTime >= 1 && $$.requestTime < 2.5 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-6"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_7" {
  name  = "${var.environment}-router-request-times-7"
  pattern        = "{$$.requestTime >= 2.5 && $$.requestTime < 5 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-7"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_8" {
  name  = "${var.environment}-router-request-times-8"
  pattern        = "{$$.requestTime >= 5 && $$.requestTime < 10 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-8"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_time_bucket_router_9" {
  name  = "${var.environment}-router-request-times-9"
  pattern        = "{$$.requestTime >= 10 && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-request-times-9"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "router-500s" {
  name  = "${var.environment}-router-500s"
  pattern        = "{$$.status = 5*}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-nginx-500s"
    namespace = "DM-500s"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "router-429s" {
  name  = "${var.environment}-router-429s"
  pattern        = "{$$.status = 429}"
  log_group_name = "${var.router_log_group_name}"

  metric_transformation {
    name  = "${var.environment}-router-nginx-429s"
    namespace = "DM-429s"
    value     = "1"
    default_value = "0"
  }
}
