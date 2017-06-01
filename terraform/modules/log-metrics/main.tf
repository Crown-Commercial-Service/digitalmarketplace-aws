resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-api" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-api-request-times-${count.index}"

  # The following resolves to something like:
  # { $.requestTime >= 0.1 && $.requestTime < 0.2 }
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.environment}-api-nginx"

  metric_transformation {
    name  = "${var.environment}-api-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-search-api" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-search-api-request-times-${count.index}"
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.environment}-search-api-nginx"

  metric_transformation {
    name  = "${var.environment}-search-api-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-buyer-frontend" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-buyer-frontend-request-times-${count.index}"
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-buyer-frontend-nginx"

  metric_transformation {
    name  = "${var.environment}-buyer-frontend-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-supplier-frontend" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-supplier-frontend-request-times-${count.index}"
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-supplier-frontend-nginx"

  metric_transformation {
    name  = "${var.environment}-supplier-frontend-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-admin-frontend" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-admin-frontend-request-times-${count.index}"
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-admin-frontend-nginx"

  metric_transformation {
    name  = "${var.environment}-admin-frontend-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-briefs-frontend" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-briefs-frontend-request-times-${count.index}"
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\" && $$.request != \"*/static/*\"}"
  log_group_name = "${var.environment}-briefs-frontend-nginx"

  metric_transformation {
    name  = "${var.environment}-briefs-frontend-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
  }
}


resource "aws_cloudwatch_log_metric_filter" "requestTimeBuckets-main-nginx" {
  count = "${length(var.request_time_buckets)}"
  name  = "${var.environment}-nginx-request-times-${count.index}"
  pattern        = "{$$.requestTime >= ${lookup(var.request_time_buckets[count.index], "min")} && $$.requestTime < ${lookup(var.request_time_buckets[count.index], "max")} && $$.request != \"*/_status?ignore-dependencies *\"}"
  log_group_name = "${var.environment}-nginx-json"

  metric_transformation {
    name  = "${var.environment}-nginx-request-times-${count.index}"
    namespace = "DM-RequestTimeBuckets"
    value     = "1"
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
  }
}

resource "aws_cloudwatch_log_metric_filter" "main-nginx-500s" {
  name  = "${var.environment}-nginx-500s"
  pattern        = "{$$.status = 5*}"
  log_group_name = "${var.environment}-nginx-json"

  metric_transformation {
    name  = "${var.environment}-nginx-500s"
    namespace = "DM-500s"
    value     = "1"
  }
}
