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
    }
  ]
}
EOF
}
