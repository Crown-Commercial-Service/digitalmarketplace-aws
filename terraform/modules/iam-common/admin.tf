resource "aws_iam_policy" "admin" {
  name = "Admin"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::${var.aws_dev_account_id}:role/s3-only"
      ]
    },
    {
      "Effect": "Deny",
      "Action": "sts:AssumeRole",
      "NotResource": [
        "arn:aws:iam::${var.aws_dev_account_id}:role/s3-only"
      ],
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": false
        }
      }
    }
  ]
}
EOF
}
