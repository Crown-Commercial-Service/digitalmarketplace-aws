resource "aws_iam_policy" "sops_credentials_access" {
  name = "SOPSCredentialsAccess"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": [
        "${aws_kms_key.sops_credentials_primary.arn}",
        "${aws_kms_key.sops_credentials_secondary.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::*:role/sops-credentials-access"
    }
  ]
}
EOF
}

resource "aws_iam_role" "sops_credentials_access" {
  name = "sops-credentials-access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sops_credentials_access" {
  role = "${aws_iam_role.sops_credentials_access.name}"
  policy_arn = "${aws_iam_policy.sops_credentials_access.arn}"
}

resource "aws_iam_policy" "assume_sops_credentials_access" {
  name = "AssumeSOPSCredentialsAccess"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "${aws_iam_role.sops_credentials_access.arn}",
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

resource "aws_iam_group_policy_attachment" "iam_group_assume_sops_credentials_access" {
  count = "${var.sops_credentials_access_iam_groups_count}"
  group = "${element(var.sops_credentials_access_iam_groups, count.index)}"
  policy_arn = "${aws_iam_policy.assume_sops_credentials_access.arn}"
}
