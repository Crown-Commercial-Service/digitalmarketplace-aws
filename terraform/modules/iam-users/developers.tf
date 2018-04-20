resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy" "developers" {
  name  = "Developers"
  group = "${aws_iam_group.developers.name}"

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
        "arn:aws:iam::${var.aws_dev_account_id}:role/developers"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::*:role/packer",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "developers_ip_restriced" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "developers" {
  name       = "developers"
  users      = ["${var.developers}"]
  group      = "${aws_iam_group.developers.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy_attachment" "developers_iam_manage_account" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "${var.iam_manage_account_policy_arn}"
}

resource "aws_iam_group" "prod_developers" {
  name = "ProdDevelopers"
}

resource "aws_iam_group_policy" "switch_to_prod_developer" {
  name  = "SwitchToProdDeveloper"
  group = "${aws_iam_group.prod_developers.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.aws_prod_account_id}:role/developers"
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "prod_developers" {
  name       = "prod_developers"
  users      = ["${var.prod_developers}"]
  group      = "${aws_iam_group.prod_developers.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group" "dev_s3_only" {
  name = "DevS3Only"
}

resource "aws_iam_group_policy_attachment" "dev_s3_only" {
  group      = "${aws_iam_group.dev_s3_only.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_group_membership" "dev_s3_only" {
  name       = "dev_s3_only"
  users      = ["${var.dev_s3_only_users}"]
  group      = "${aws_iam_group.dev_s3_only.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group_policy_attachment" "dev_s3_only_iam_manage_account" {
  group      = "${aws_iam_group.dev_s3_only.name}"
  policy_arn = "${var.iam_manage_account_policy_arn}"
}

resource "aws_iam_policy" "dev_uploads_s3_access" {
  name = "devUploadsS3Access"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::digitalmarketplace-dev-uploads"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::digitalmarketplace-dev-uploads/*"
    }
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "developers_dev_uploads_s3" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "${aws_iam_policy.dev_uploads_s3_access.arn}"
}

resource "aws_iam_group_policy_attachment" "dev_s3_only_dev_uploads_s3" {
  group      = "${aws_iam_group.dev_s3_only.name}"
  policy_arn = "${aws_iam_policy.dev_uploads_s3_access.arn}"
}
