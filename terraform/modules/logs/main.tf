resource "aws_cloudwatch_log_stream" "cloudwatch_stream" {
  name = "${var.stream_name}"
  log_group_name = "${var.group_name}"
}

resource "aws_iam_role_policy_attachment" "allow_logging" {
  role = "${var.iam_role_id}"
  policy_arn = "${var.cloudwatch_policy_arn}"
}
