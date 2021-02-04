resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "${var.trail_name}-cloudtrail-log-group"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "cloud_watch_logs_role" {
  name = "CloudTrail_CloudWatchLogs_Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloud_watch_policy" {
  name = "CloudWatch-policy"
  role = aws_iam_role.cloud_watch_logs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}"
      ]
    }
  ]
}
EOF
}
