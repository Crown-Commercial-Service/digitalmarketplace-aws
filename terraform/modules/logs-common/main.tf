resource "aws_cloudwatch_log_group" "plaintext_logs" {
  name = "${var.name}"
}

resource "aws_cloudwatch_log_group" "json_logs" {
  name = "${var.name}-json"
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
      "${aws_cloudwatch_log_group.plaintext_logs.arn}",
      "${aws_cloudwatch_log_group.json_logs.arn}"
    ]
  }]
}
ENDPOLICY
}
