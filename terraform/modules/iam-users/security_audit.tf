resource "aws_iam_group" "security_audit" {
  name = "SecurityAudit"
}

resource "aws_iam_group_policy" "security_audit_assume_role" {
  name  = "SecurityAuditAssumeRole"
  group = "${aws_iam_group.security_audit.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [
        "arn:aws:iam::${var.aws_dev_account_id}:role/security_audit",
        "arn:aws:iam::${var.aws_prod_account_id}:role/security_audit"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "security_audit_policy" {
  group      = "${aws_iam_group.security_audit.name}"
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_group_policy_attachment" "read_only_access_policy" {
  group      = "${aws_iam_group.security_audit.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "security_audit_ip_restricted" {
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
