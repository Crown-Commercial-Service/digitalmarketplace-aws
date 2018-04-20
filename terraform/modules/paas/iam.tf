resource "aws_iam_user" "paas_app" {
  name = "paas-app"
}

resource "aws_iam_user_policy" "paas_app_policy" {
  user = "${aws_iam_user.paas_app.name}"
  name = "PaaSAppPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Put*",
        "s3:DeleteObject"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups"
      ],
      "Resource": "arn:aws:logs:eu-west-1:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "paas_metrics_collector" {
  name = "paas-metrics-collector"
}

resource "aws_iam_user_policy" "grafana" {
  user = "${aws_iam_user.paas_metrics_collector.name}"
  name = "Grafana"

  policy = <<EOF
{
    "Statement": [
        {
            "Sid": "PermissionsForMetrics",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes"
            ],
            "Resource": [ "*" ]
        },
        {
            "Sid": "PermissionsForTags",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": [ "*" ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}
