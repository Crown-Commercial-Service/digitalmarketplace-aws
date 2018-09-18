data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Log groups for success and failure feedback - the names are defaults defined by AWS
resource "aws_cloudwatch_log_group" "antivirus_sns_logs_success" {
  name              = "sns/${data.aws_region.current.name}/${data.aws_caller_identity.current.account_id}/${aws_sns_topic.s3_file_upload_notification.name}"
  retention_in_days = "${var.retention_in_days}"
}

resource "aws_cloudwatch_log_group" "antivirus_sns_logs_failure" {
  name              = "sns/${data.aws_region.current.name}/${data.aws_caller_identity.current.account_id}/${aws_sns_topic.s3_file_upload_notification.name}/Failure"
  retention_in_days = "${var.retention_in_days}"
}

# Permissions for the lambda function on the log groups
resource "aws_lambda_permission" "cloudwatch_antivirus_sns_logs_success" {
  statement_id  = "cloudwatch-lambda-antivirus-sns-logs-success"
  action        = "lambda:InvokeFunction"
  function_name = "${var.log_stream_lambda_arn}"
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.antivirus_sns_logs_success.name}:*"
}

resource "aws_lambda_permission" "cloudwatch_antivirus_sns_logs_failure" {
  statement_id  = "cloudwatch-lambda-antivirus-sns-logs-failure"
  action        = "lambda:InvokeFunction"
  function_name = "${var.log_stream_lambda_arn}"
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.antivirus_sns_logs_failure.name}:*"
}

# Subscriptions for the success and failure feedback logs to be sent to the lambda
resource "aws_cloudwatch_log_subscription_filter" "elasticsearch_subscription_antivirus_sns_logs_success" {
  name            = "elasticsearch-subscription-antivirus-sns-logs-success"
  log_group_name  = "${aws_cloudwatch_log_group.antivirus_sns_logs_success.name}"
  filter_pattern  = "{ $.status = \"SUCCESS\" }"
  destination_arn = "${var.log_stream_lambda_arn}"
  depends_on      = ["aws_lambda_permission.cloudwatch_antivirus_sns_logs_success"]
}

resource "aws_cloudwatch_log_subscription_filter" "elasticsearch_subscription_antivirus_sns_logs_failure" {
  name            = "elasticsearch-subscription-antivirus-sns-logs-failure"
  log_group_name  = "${aws_cloudwatch_log_group.antivirus_sns_logs_failure.name}"
  filter_pattern  = "{ $.status = \"FAILURE\" }"
  destination_arn = "${var.log_stream_lambda_arn}"
  depends_on      = ["aws_lambda_permission.cloudwatch_antivirus_sns_logs_failure"]
}
