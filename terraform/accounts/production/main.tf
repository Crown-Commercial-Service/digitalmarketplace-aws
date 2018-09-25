provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-production"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-production"
    key     = "accounts/production/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "iam_common" {
  source              = "../../modules/iam-common"
  dev_user_ips        = "${var.dev_user_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id  = "${var.aws_dev_account_id}"
}

module "switch_roles" {
  source                          = "../../modules/switch-roles"
  ip_restricted_access_policy_arn = "${module.iam_common.aws_iam_policy_ip_restricted_access_arn}"
  iam_manage_account_policy_arn   = "${module.iam_common.aws_iam_policy_iam_manage_account_arn}"
  aws_main_account_id             = "${var.aws_main_account_id}"
}

module "paas" {
  source = "../../modules/paas"
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
