resource "aws_iam_group" "security_audit" {
  name = "Security Audit"
}

resource "aws_iam_group_policy_attachment" "security_audit_policy" {
  group      = "${aws_iam_group.security_audit.name}"
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_group_policy_attachment" "read_only_access_policy" {
  group      = "${aws_iam_group.security_audit.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "developers_ip_restriced" {
  group      = "${aws_iam_group.security_audit.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "security_audit" {
  name       = "security_audit"
  users      = ["${var.security_audit_users}"]
  group      = "${aws_iam_group.security_audit.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy_attachment" "security_audit_iam_manage_account" {
  group      = "${aws_iam_group.security_audit.name}"
  policy_arn = "${var.iam_manage_account_policy_arn}"
}
