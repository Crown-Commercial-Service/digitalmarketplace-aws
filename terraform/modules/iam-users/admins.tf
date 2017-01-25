resource "aws_iam_group" "admins" {
  name = "Admins"
}

resource "aws_iam_group_policy_attachment" "admins_ip_restriced" {
  group = "${aws_iam_group.admins.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "admins_mfa_restriced" {
  group = "${aws_iam_group.admins.name}"
  policy_arn = "${var.mfa_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "admins" {
  name = "Admins"
  users = [
    "${var.admin_users}"
  ]
  group = "${aws_iam_group.admins.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy_attachment" "admins" {
  group = "${aws_iam_group.admins.id}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
