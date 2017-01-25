resource "aws_iam_group" "ansible" {
  name = "Ansible"
}

resource "aws_iam_group_policy_attachment" "ansible_ip_restriced" {
  group = "${aws_iam_group.ansible.name}"
  policy_arn = "${aws_iam_policy.ip_restricted_access.arn}"
}

resource "aws_iam_group_policy" "ansible" {
  name = "Ansible"
  group = "${aws_iam_group.ansible.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstance*",
        "ec2:CreateSnapshot",
        "ec2:DescribeSnapshot*",
        "ec2:ModifySnapshotAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DescribeVolume*",
        "ec2:DetachVolume",
        "ec2:ModifyVolumeAttribute",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeTags",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:DescribeImages",
        "ec2:GetPasswordData",
        "ec2:DeregisterImage",
        "ec2:DeleteSnapshot",
        "rds:Describe*",
        "elasticache:Describe*"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "ansible" {
  name = "ansible"
  users = ["${var.ansible_users}"]
  group = "${aws_iam_group.ansible.name}"
  depends_on = ["module.users"]
}
