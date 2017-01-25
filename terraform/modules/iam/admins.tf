resource "aws_iam_group" "admins" {
  name = "Admins"
}

resource "aws_iam_group_policy_attachment" "admins_ip_restriced" {
  group = "${aws_iam_group.admins.name}"
  policy_arn = "${aws_iam_policy.ip_restricted_access.arn}"
}

resource "aws_iam_group_policy_attachment" "admins_mfa_restriced" {
  group = "${aws_iam_group.admins.name}"
  policy_arn = "${aws_iam_policy.mfa_restricted_access.arn}"
}

resource "aws_iam_group_membership" "admins" {
  name = "admin"
  users = [
    "${var.admin_users}"
  ]
  group = "${aws_iam_group.admins.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy" "admins" {
  name = "admin"
  group = "${aws_iam_group.admins.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}
