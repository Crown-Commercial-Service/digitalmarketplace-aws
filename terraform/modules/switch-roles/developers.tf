provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.70"
}

resource "aws_iam_policy" "developer" {
  name = "Developer"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:Describe*",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "ec2:*NetworkAcl*",
        "ec2:AllocateAddress",
        "ec2:AssociateAddress",
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:Describe*",
        "ec2:DetachVolume",
        "ec2:DisassociateAddress",
        "ec2:ModifyInstanceAttribute",
        "ec2:RebootInstances",
        "ec2:ReleaseAddress",
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "elasticache:Describe*",
        "elasticache:List*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "es:Describe*",
        "es:List*",
        "events:Describe*",
        "events:List*",
        "events:TestEventPattern",
        "kms:DescribeKey",
        "kms:List*",
        "logs:Describe*",
        "logs:FilterLogEvents",
        "logs:Get*",
        "logs:TestMetricFilter",
        "rds:Describe*",
        "rds:ListTagsForResource",
        "route53:Get*",
        "route53:List*",
        "s3:Get*",
        "s3:List*",
        "sns:Get*",
        "sns:List*",
        "sqs:Get*",
        "sqs:List*"
      ],
      "Effect": "Allow",
      "Resource": "*",
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

resource "aws_iam_role" "developers" {
  name = "developers"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_main_account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "developers_ip_restriced" {
  role       = aws_iam_role.developers.name
  policy_arn = var.ip_restricted_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "developers_developer" {
  role       = aws_iam_role.developers.id
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_role_policy_attachment" "developers_iam_manage_account" {
  role       = aws_iam_role.developers.name
  policy_arn = var.iam_manage_account_policy_arn
}

