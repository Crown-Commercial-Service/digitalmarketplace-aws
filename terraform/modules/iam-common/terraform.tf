resource "aws_iam_policy" "terraform" {
  name = "Terraform"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::digitalmarketplace-terraform-state*/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::digitalmarketplace-terraform-state*/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_group" "terraform" {
  name = "Terraform"
}

resource "aws_iam_group_policy_attachment" "terraform_ip_restriced" {
  group = "${aws_iam_group.terraform.name}"
  policy_arn = "${aws_iam_policy.ip_restricted_access.arn}"
}

resource "aws_iam_group_policy_attachment" "terraform_terraform" {
  group = "${aws_iam_group.terraform.id}"
  policy_arn = "${aws_iam_policy.terraform.arn}"
}

resource "aws_iam_user" "andras_terraform" {
  name = "andras-terraform"
}

resource "aws_iam_group_membership" "terraform" {
  name = "terraform"
  users = [
    "${aws_iam_user.andras_terraform.name}"
  ]
  group = "${aws_iam_group.terraform.name}"
}
