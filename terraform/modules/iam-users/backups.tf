resource "aws_iam_group" "backups" {
  name = "backups"
}

resource "aws_iam_group_policy" "backups" {
  name  = "Backups"
  group = "${aws_iam_group.backups.name}"

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
        "arn:aws:iam::${var.aws_backups_account_id}:role/backups"
      ]
    }
  ]
}
EOF
}

// Add the common IP restriction policy to the backups group
resource "aws_iam_group_policy_attachment" "backups_ip_restriced" {
  group      = "${aws_iam_group.backups.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "backups" {
  name       = "Backups"
  users      = ["${var.backups}"]
  group      = "${aws_iam_group.backups.name}"
  depends_on = ["module.users"]
}



