provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.70"
}

data "aws_iam_policy_document" "snapshot_jenkins_data_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "snapshot_jenkins_data_policy" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]

    resources = ["*"]
  }

  statement {
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*::snapshot/*"]
  }
}

resource "aws_iam_role" "snapshot_jenkins_data_role" {
  name               = "snapshot-jenkins-data-role"
  assume_role_policy = data.aws_iam_policy_document.snapshot_jenkins_data_role.json
}

resource "aws_iam_role_policy" "snapshot_jenkins_data_policy" {
  name   = "snapshot-jenkins-data-policy"
  role   = aws_iam_role.snapshot_jenkins_data_role.id
  policy = data.aws_iam_policy_document.snapshot_jenkins_data_policy.json
}

resource "aws_dlm_lifecycle_policy" "snapshot_jenkins_data" {
  description        = "Snapshot the Jenkins data volume daily around midnight and retain snapshots for a week"
  execution_role_arn = aws_iam_role.snapshot_jenkins_data_role.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "One week of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:30"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true
    }

    target_tags = {
      Name = "jenkins data"
    }
  }
}

