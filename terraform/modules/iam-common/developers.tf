resource "aws_iam_policy" "developer" {
  name = "Developer"
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
        "kms:List*",
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances",
        "ec2:TerminateInstances",
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:AllocateAddress",
        "ec2:AssociateAddress",
        "ec2:*NetworkAcl*",
        "ec2:DisassociateAddress",
        "ec2:ModifyInstanceAttribute",
        "ec2:ReleaseAddress",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
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
