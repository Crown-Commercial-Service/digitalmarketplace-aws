# Other buckets should be set to log to this bucket
data "aws_iam_policy_document" "server_access_logs_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-logs-staging-staging/*",
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

resource "aws_s3_bucket" "server_access_logs_bucket" {
  bucket = "digitalmarketplace-logs-staging-staging"
  acl    = "log-delivery-write"
  policy = "${data.aws_iam_policy_document.server_access_logs_bucket_policy_document.json}"

  versioning {
    enabled = true
  }
}

# TODO remove these hard-coded definitions in favour of using the terraform/modules/s3-document-bucket module after the
# tf v0.12 upgrade. We need to contitionally include the principals block

# Agreements - jenkins: listversions

data "aws_iam_policy_document" "agreements_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-agreements-staging-staging/*",
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
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"]
      type        = "AWS"
    }

    actions = [
      "s3:ListBucketVersions",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-agreements-staging-staging",
    ]
  }
}

resource "aws_s3_bucket" "agreements_bucket" {
  bucket = "digitalmarketplace-agreements-staging-staging"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-agreements-staging-staging/"
  }

  policy = "${data.aws_iam_policy_document.agreements_bucket_policy_document.json}"
}

# Reports - jenkins: read write list

data "aws_iam_policy_document" "reports_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-reports-staging-staging/*",
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
    effect = "Allow"

    principals {
      identifiers = [
        "arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ",
      ]

      type = "AWS"
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-reports-staging-staging/*",
      "arn:aws:s3:::digitalmarketplace-reports-staging-staging",
    ]
  }
}

resource "aws_s3_bucket" "reports_bucket" {
  bucket = "digitalmarketplace-reports-staging-staging"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-reports-staging-staging/"
  }

  policy = "${data.aws_iam_policy_document.reports_bucket_policy_document.json}"
}

# Communications - jenkins: listversions

data "aws_iam_policy_document" "communications_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-communications-staging-staging/*",
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
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"]
      type        = "AWS"
    }

    actions = [
      "s3:ListBucketVersions",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-communications-staging-staging",
    ]
  }
}

resource "aws_s3_bucket" "communications_bucket" {
  bucket = "digitalmarketplace-communications-staging-staging"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-communications-staging-staging/"
  }

  policy = "${data.aws_iam_policy_document.communications_bucket_policy_document.json}"
}

# Documents - jenkins: read write list listversions

data "aws_iam_policy_document" "documents_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-documents-staging-staging/*",
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
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"]
      type        = "AWS"
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-documents-staging-staging/*",
      "arn:aws:s3:::digitalmarketplace-documents-staging-staging",
    ]
  }
}

resource "aws_s3_bucket" "documents_bucket" {
  bucket = "digitalmarketplace-documents-staging-staging"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-documents-staging-staging/"
  }

  policy = "${data.aws_iam_policy_document.documents_bucket_policy_document.json}"
}

# G7-draft-documents

data "aws_iam_policy_document" "g7-draft-documents_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-g7-draft-documents-staging-staging/*",
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

resource "aws_s3_bucket" "g7-draft-documents_bucket" {
  bucket = "digitalmarketplace-g7-draft-documents-staging-staging"
  acl    = "private"
  policy = "${data.aws_iam_policy_document.g7-draft-documents_bucket_policy_document.json}"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-g7-draft-documents-staging-staging/"
  }
}

# Submissions - jenkins: listversions

data "aws_iam_policy_document" "submissions_bucket_policy_document" {
  statement {
    effect = "Deny"

    principals = {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-submissions-staging-staging/*",
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
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"]
      type        = "AWS"
    }

    actions = [
      "s3:ListBucketVersions",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-submissions-staging-staging",
    ]
  }
}

resource "aws_s3_bucket" "submissions_bucket" {
  bucket = "digitalmarketplace-submissions-staging-staging"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-submissions-staging-staging/"
  }

  policy = "${data.aws_iam_policy_document.submissions_bucket_policy_document.json}"
}
