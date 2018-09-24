provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-development"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-development"
    key     = "accounts/development/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "aws_env" {
  source              = "../../modules/aws-env"
  dev_user_ips        = "${var.dev_user_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id  = "${var.aws_dev_account_id}"
}

### TEMPORARY PAAS USER

resource "aws_iam_user" "paas_app" {
  name = "paas-app-TEMP"
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

### TEMPORARY PAAS METRICS USER

resource "aws_iam_user" "paas_metrics_collector" {
  name = "paas-metrics-collector-TEMP"
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
