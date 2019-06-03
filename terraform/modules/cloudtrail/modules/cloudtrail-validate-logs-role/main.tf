data "aws_iam_policy_document" "cloudtrail_validate_logs_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${var.assume_role_arn}"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_validate_logs_policy" {
  statement {
    actions = [
      "cloudtrail:ListPublicKeys",
      "cloudtrail:DescribeTrails",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = ["${var.s3_bucket_arn}"]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_role" "cloudtrail_validate_logs_role" {
  name               = "cloudtrail-validate-logs"
  assume_role_policy = "${data.aws_iam_policy_document.cloudtrail_validate_logs_role.json}"
}

resource "aws_iam_role_policy" "cloudtrail_validate_logs_policy" {
  name   = "cloudtrail-validate-logs"
  role   = "${aws_iam_role.cloudtrail_validate_logs_role.id}"
  policy = "${data.aws_iam_policy_document.cloudtrail_validate_logs_policy.json}"
}
