provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.70"
}

data "aws_iam_policy_document" "document_bucket_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = var.read_object_roles
      type        = "AWS"
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}/*",
      "arn:aws:s3:::digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}",
    ]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = var.write_object_roles
      type        = "AWS"
    }

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}/*",
      "arn:aws:s3:::digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}",
    ]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = var.list_bucket_roles
      type        = "AWS"
    }

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}/*",
      "arn:aws:s3:::digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}",
    ]
  }
}

resource "aws_s3_bucket" "document_bucket" {
  bucket = "digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}"
  acl    = "private"

  versioning {
    enabled    = true
    mfa_delete = true
  }

  logging {
    target_bucket = var.log_bucket_name
    target_prefix = "digitalmarketplace-${var.bucket_name}-${var.environment}-${var.environment}/"
  }

  policy = data.aws_iam_policy_document.document_bucket_policy_document.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

