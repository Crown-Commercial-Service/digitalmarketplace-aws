resource "aws_iam_group" "packer" {
  name = "Packer"
}

resource "aws_iam_group_policy_attachment" "packer_ip_restriced" {
  group = "${aws_iam_group.packer.name}"
  policy_arn = "${aws_iam_policy.ip_restricted_access.arn}"
}

resource "aws_iam_group_policy" "packer" {
  name = "Packer"
  group = "${aws_iam_group.packer.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "PackerSecurityGroupAccess",
      "Action": [
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "PackerAMIAccess",
      "Action": [
        "ec2:CreateImage",
        "ec2:RegisterImage",
        "ec2:DeregisterImage",
        "ec2:DescribeImages",
        "ec2:ModifyImageAttribute"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "PackerSnapshotAccess",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:DescribeSnapshots"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "PackerInstanceAccess",
      "Action": [
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances",
        "ec2:TerminateInstances",
        "ec2:DescribeInstances",
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "PackerVolumeAccess",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeVolume*",
        "ec2:DetachVolume"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "PackerKeyPairAccess",
      "Action": [
        "ec2:DescribeKeyPairs"
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

resource "aws_iam_group_membership" "packer" {
  name = "packer"
  users = ["${var.packer_users}"]
  group = "${aws_iam_group.packer.name}"
  depends_on = ["module.users"]
}
