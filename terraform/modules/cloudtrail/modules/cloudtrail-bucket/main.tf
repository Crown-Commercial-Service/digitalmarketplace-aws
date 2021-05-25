data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }

  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
