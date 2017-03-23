resource "aws_iam_policy" "ip_restricted_access" {
  name = "IPRestrictedAccess"
  description = "Require requests to come from one of the Office IPs or admin servers (e.g. Jenkins)"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "NotIpAddress": {
        "aws:SourceIp": [${join(",", formatlist("\"%s\"", var.dev_user_ips))}]
      },
      "Null": {
        "kms:ViaService": "true"
      }
    }
  }
}
EOF
}

resource "aws_iam_policy" "iam_manage_account" {
  name = "IAMManageAccount"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListUsers",
        "iam:ListVirtualMFADevices"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ChangePassword",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices"
      ],
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateVirtualMFADevice"
      ],
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:*LoginProfile",
        "iam:*AccessKey*",
        "iam:*SSHPublicKey*",
        "iam:ListGroupsForUser"
      ],
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListAccount*",
        "iam:GetAccountSummary",
        "iam:GetAccountPasswordPolicy",
        "iam:GetGroup",
        "iam:ListUsers",
        "iam:ListGroups"
      ],
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
