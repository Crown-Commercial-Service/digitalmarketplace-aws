resource "aws_iam_role" "developers" {
  name = "developers"
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

resource "aws_iam_role_policy_attachment" "developers_ip_restriced" {
  role = "${aws_iam_role.developers.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "developers_developer" {
  role = "${aws_iam_role.developers.id}"
  policy_arn = "${var.developer_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "developers_iam_manage_account" {
  role = "${aws_iam_role.developers.name}"
  policy_arn = "${var.iam_manage_account_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "developers_s3_only" {
  role = "${aws_iam_role.developers.name}"
  policy_arn = "${aws_iam_policy.s3_only.arn}"
}
