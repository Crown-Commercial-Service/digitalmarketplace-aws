# Cross Region replication buckets

data "aws_iam_policy_document" "cross_region_documents_s3_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cross-region-documents-preview-preview/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}

resource "aws_s3_bucket" "cross_region_documents_s3_bucket" {
  provider = aws.london
  bucket   = "digitalmarketplace-cross-region-documents-preview-preview"
  acl      = "private"
  policy   = data.aws_iam_policy_document.cross_region_documents_s3_bucket_policy_document.json

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "cross_region_agreements_s3_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cross-region-agreements-preview-preview/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}

resource "aws_s3_bucket" "cross_region_agreements_s3_bucket" {
  provider = aws.london
  bucket   = "digitalmarketplace-cross-region-agreements-preview-preview"
  acl      = "private"
  policy   = data.aws_iam_policy_document.cross_region_agreements_s3_bucket_policy_document.json

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "cross_region_communications_s3_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cross-region-communications-preview-preview/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}

resource "aws_s3_bucket" "cross_region_communications_s3_bucket" {
  provider = aws.london
  bucket   = "digitalmarketplace-cross-region-communications-preview-preview"
  acl      = "private"
  policy   = data.aws_iam_policy_document.cross_region_communications_s3_bucket_policy_document.json

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "cross_region_submissions_s3_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cross-region-submissions-preview-preview/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}

resource "aws_s3_bucket" "cross_region_submissions_s3_bucket" {
  provider = aws.london
  bucket   = "digitalmarketplace-cross-region-submissions-preview-preview"
  acl      = "private"
  policy   = data.aws_iam_policy_document.cross_region_submissions_s3_bucket_policy_document.json

  versioning {
    enabled = true
  }
}

