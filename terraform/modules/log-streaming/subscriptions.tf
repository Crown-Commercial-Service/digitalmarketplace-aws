data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "cloudwatch_nginx" {
  count         = "${length(var.nginx_log_groups)}"
  statement_id  = "cloudwatch-lambda-${element(var.nginx_log_groups, count.index)}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.log_stream_lambda.arn}"
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${element(var.nginx_log_groups, count.index)}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "elasticsearch_subscription_nginx" {
  count           = "${length(var.nginx_log_groups)}"
  name            = "elasticsearch-subscription-${element(var.nginx_log_groups, count.index)}"
  log_group_name  = "${element(var.nginx_log_groups, count.index)}"
  filter_pattern  = "{ $.request != \"*/_status?ignore-dependencies *\" }"
  destination_arn = "${aws_lambda_function.log_stream_lambda.arn}"
  depends_on      = ["aws_lambda_permission.cloudwatch_nginx"]
}

resource "aws_lambda_permission" "cloudwatch_application" {
  count         = "${length(var.application_log_groups)}"
  statement_id  = "cloudwatch-lambda-${element(var.application_log_groups, count.index)}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.log_stream_lambda.arn}"
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${element(var.application_log_groups, count.index)}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "elasticsearch_subscription_application" {
  count           = "${length(var.application_log_groups)}"
  name            = "elasticsearch-subscription-${element(var.application_log_groups, count.index)}"
  log_group_name  = "${element(var.application_log_groups, count.index)}"
  filter_pattern  = "{ $.url NOT EXISTS || $.url != \"*/_status?ignore-dependencies\" }"
  destination_arn = "${aws_lambda_function.log_stream_lambda.arn}"
  depends_on      = ["aws_lambda_permission.cloudwatch_application"]
}
