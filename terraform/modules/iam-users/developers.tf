resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_ip_restriced" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers"
  users = ["${var.developer_users}"]
  group = "${aws_iam_group.developers.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy_attachment" "developers_developer" {
  group = "${aws_iam_group.developers.id}"
  policy_arn = "${var.developer_policy_arn}"
}

resource "aws_iam_group_policy_attachment" "developers_iam_manage_account" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${var.iam_manage_account_policy_arn}"
}
