resource "aws_iam_group" "dev_infrastructure" {
  name = "DevInfrastructure"
}

resource "aws_iam_group_policy" "dev_infrastructure" {
  name  = "DevInfrastructure"
  group = "${aws_iam_group.dev_infrastructure.name}"

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
        "arn:aws:iam::${var.aws_dev_account_id}:role/infrastructure",
        "arn:aws:iam::${var.aws_dev_account_id}:role/packer"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "dev_infrastructure" {
  name       = "dev_infrastructure"
  users      = ["${var.dev_infrastructure_users}"]
  group      = "${aws_iam_group.dev_infrastructure.name}"
  depends_on = ["module.users"]
}

resource "aws_iam_group" "prod_infrastructure" {
  name = "ProdInfrastructure"
}

resource "aws_iam_group_policy" "prod_infrastructure" {
  name  = "ProdInfrastructure"
  group = "${aws_iam_group.prod_infrastructure.name}"

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
        "arn:aws:iam::${var.aws_prod_account_id}:role/infrastructure",
        "arn:aws:iam::${var.aws_prod_account_id}:role/packer"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "prod_infrastructure" {
  name       = "prod_infrastructure"
  users      = ["${var.prod_infrastructure_users}"]
  group      = "${aws_iam_group.prod_infrastructure.name}"
  depends_on = ["module.users"]
}
