resource "aws_iam_group" "switch_to_dev_developer" {
  name = "SwitchToDevDeveloper"
}

resource "aws_iam_group_policy" "switch_to_dev_developer" {
  name = "SwitchToDevDeveloper"
  group = "${aws_iam_group.switch_to_dev_developer.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.aws_dev_account_id}:role/Developers"
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "switch_to_dev_developer" {
  name = "switch_to_dev_developer"
  users = ["${var.switch_to_dev_developer_users}"]
  group = "${aws_iam_group.switch_to_dev_developer.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group" "switch_to_prod_developer" {
  name = "SwitchToProdDeveloper"
}

resource "aws_iam_group_policy" "switch_to_prod_developer" {
  name = "SwitchToProdDeveloper"
  group = "${aws_iam_group.switch_to_prod_developer.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.aws_prod_account_id}:role/Developers"
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "switch_to_prod_developer" {
  name = "switch_to_prod_developer"
  users = ["${var.switch_to_prod_developer_users}"]
  group = "${aws_iam_group.switch_to_prod_developer.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group" "switch_to_dev_s3_only" {
  name = "SwitchToDevS3Only"
}

resource "aws_iam_group_policy" "switch_to_dev_s3_only" {
  name = "SwitchToDevS3Only"
  group = "${aws_iam_group.switch_to_dev_s3_only.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.aws_dev_account_id}:role/S3Only"
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "switch_to_dev_s3_only" {
  name = "developer_switch_to_prod"
  users = ["${var.switch_to_dev_s3_only_users}"]
  group = "${aws_iam_group.switch_to_dev_s3_only.name}"
  depends_on = ["module.users"]
}
