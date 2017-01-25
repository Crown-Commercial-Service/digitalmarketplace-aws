resource "aws_iam_role" "admins" {
  name = "Admins"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.source_aws_account_id}:root"
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

resource "aws_iam_role_policy_attachment" "admins_ip_restriced" {
  role = "${aws_iam_role.admins.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "admins_mfa_restriced" {
  role = "${aws_iam_role.admins.name}"
  policy_arn = "${var.mfa_restricted_access_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "admins" {
  role = "${aws_iam_role.admins.id}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
