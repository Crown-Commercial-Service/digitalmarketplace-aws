resource "aws_iam_role" "security_audit" {
  name = "security_audit"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_main_account_id}:root"
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

resource "aws_iam_role_policy_attachment" "security_audit_security_audit" {
  role       = "${aws_iam_role.security_audit.id}"
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "security_audit_read_only" {
  role       = "${aws_iam_role.security_audit.id}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "security_audit_ip_restricted" {
  role       = "${aws_iam_role.security_audit.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}
