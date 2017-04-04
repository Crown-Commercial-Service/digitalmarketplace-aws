resource "aws_cloudwatch_log_group" "logs" {
  name = "${var.name}"
  retention_in_days = "${var.log_retention_days}"
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name = "${var.name}-cloudwatch"
  policy = <<ENDPOLICY
{
  "Version" : "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ],
    "Resource": [
      "${aws_cloudwatch_log_group.logs.arn}"
  ]
  }]
}
ENDPOLICY
}

resource "aws_iam_role_policy_attachment" "allow_logging" {
  role = "${var.iam_role_id}"
  policy_arn = "${aws_iam_policy.cloudwatch_policy.arn}"
}
