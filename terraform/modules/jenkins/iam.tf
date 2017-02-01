resource "aws_iam_role" "jenkins" {
  name = "jenkins-ci-IAMRole-1FIPDG9DE2CWJ"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ci-InstanceProfile-AOFDQ580SQSK"
  roles = ["${aws_iam_role.jenkins.id}"]
}

resource "aws_iam_role_policy" "assume_roles" {
  name = "AssumeRoles"
  role = "${aws_iam_role.jenkins.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [${join(",", formatlist("\"arn:aws:iam::%s:role/infrastructure\"", var.aws_sub_account_ids))}]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.aws_main_account_id}:role/sops-credentials-access"
    }
  ]
}
EOF
}
