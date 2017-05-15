data "aws_region" "current" {
  current = true
}

resource "aws_lambda_permission" "cloudwatch" {
  count = "${length(var.log_groups)}"
  statement_id = "cloudwatch-lambda-${element(var.log_groups, count.index)}"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.log_stream_lambda.arn}"
  principal = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn = "arn:aws:logs:${data.aws_region.current.name}:${var.aws_account_id}:log-group:${element(var.log_groups, count.index)}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "elasticsearch-subscription" {
  count = "${length(var.log_groups)}"
  name = "elasticsearch-subscription-${element(var.log_groups, count.index)}"
  log_group_name = "${element(var.log_groups, count.index)}"
  filter_pattern = ""
  destination_arn = "${aws_lambda_function.log_stream_lambda.arn}"
  depends_on = ["aws_lambda_permission.cloudwatch"]
}
