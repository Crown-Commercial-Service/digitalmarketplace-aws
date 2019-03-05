resource "aws_iam_group" "admins" {
  name = "Admins"
}

resource "aws_iam_group_policy_attachment" "admins_admin" {
  group      = "${aws_iam_group.admins.name}"
  policy_arn = "${var.admin_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "admins_ip_restriced" {
  group      = "${aws_iam_group.admins.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "admins_dev_uploads_s3" {
  group      = "${aws_iam_group.admins.name}"
  policy_arn = "${aws_iam_policy.dev_s3_access.arn}"
}

resource "aws_iam_group_membership" "admins" {
  name       = "Admins"
  users      = ["${var.admins}"]
  group      = "${aws_iam_group.admins.name}"
  depends_on = ["module.users"]
}
