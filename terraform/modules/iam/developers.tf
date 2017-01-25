resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_ip_restriced" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${aws_iam_policy.ip_restricted_access.arn}"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers"
  users = ["${var.developer_users}"]
  group = "${aws_iam_group.developers.name}"
}

resource "aws_iam_policy" "developers" {
  name = "Developers"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:Get*",
        "sqs:List*",
        "autoscaling:Describe*",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "logs:Get*",
        "logs:FilterLogEvents",
        "logs:Describe*",
        "logs:TestMetricFilter",
        "sns:Get*",
        "sns:List*",
        "rds:Describe*",
        "rds:ListTagsForResource",
        "ec2:Describe*",
        "elasticloadbalancing:Describe*",
        "es:Describe*",
        "es:List*",
        "s3:ListAllMyBuckets",
        "elasticache:Describe*",
        "elasticache:List*",
        "route53:Get*",
        "route53:List*",
        "events:Describe*",
        "events:List*",
        "events:TestEventPattern",
        "kms:DescribeKey",
        "kms:List*"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*/*"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "developers_developers" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${aws_iam_policy.developers.arn}"
}

resource "aws_iam_group_policy_attachment" "developers_iam_manage_account" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${aws_iam_policy.iam_manage_account.arn}"
}

resource "aws_iam_group_policy_attachment" "developers_sops_credentials_access" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${var.sops_credentials_access_policy_arn}"
}
