resource "aws_iam_group" "basic_users" {
  name = "BasicUsers"
}

resource "aws_iam_group_policy_attachment" "basic_users_ip_restriced" {
  group = "${aws_iam_group.basic_users.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "basic_users" {
  name = "basic_users"
  users = ["${var.basic_users}"]
  group = "${aws_iam_group.basic_users.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy_attachment" "basic_users_iam_manage_account" {
  group = "${aws_iam_group.basic_users.name}"
  policy_arn = "${var.iam_manage_account_policy_arn}"
}
