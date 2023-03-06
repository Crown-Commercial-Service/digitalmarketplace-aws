resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
}

data "aws_iam_policy_document" "write_log_group" {
  version = "2012-10-17"

  statement {
    sid = "DescribeAllLogGroups" # Deliberately named so that identical statements overwrite each other

    actions = [
      "logs:DescribeLogGroups"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }

  statement {
    sid = "Write${replace(var.log_group_name, "-", "")}LogGroup"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.log_group.arn}:*"
    ]
  }

  statement {
    sid = "Write${replace(var.log_group_name, "-", "")}LogStream"
    actions = [
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.log_group.arn}:log-stream:*"
    ]
  }
}
