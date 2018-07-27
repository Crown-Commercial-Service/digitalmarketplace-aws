# Other buckets should be set to log to this bucket
resource "aws_s3_bucket" "server_access_logs_bucket" {
  bucket = "digitalmarketplace-logs-production-production"
  acl    = "log-delivery-write"

  versioning {
    enabled = true
  }
}

# TODO remove these hard-coded definitions in favour of using the terraform/modules/s3-document-bucket module after the
# tf v0.12 upgrade. We need to contitionally include the principals block

# Agreements - devs: read write list jenkins: read write list

data "aws_iam_policy_document" "agreements_bucket_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "arn:aws:iam::${var.aws_prod_account_id}:role/developers",
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
      "arn:aws:s3:::digitalmarketplace-agreements-production-production/*",
      "arn:aws:s3:::digitalmarketplace-agreements-production-production",
    ]
  }
}

resource "aws_s3_bucket" "agreements_bucket" {
  bucket = "digitalmarketplace-agreements-production-production"
  acl    = "private"

  versioning {
    enabled    = true
    mfa_delete = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-agreements-production-production/"
  }

  policy = "${data.aws_iam_policy_document.agreements_bucket_policy_document.json}"
}

# Communications jenkins: read write

data "aws_iam_policy_document" "communications_bucket_policy_document" {
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
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-communications-production-production/*",
      "arn:aws:s3:::digitalmarketplace-communications-production-production",
    ]
  }
}

resource "aws_s3_bucket" "communications_bucket" {
  bucket = "digitalmarketplace-communications-production-production"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-communications-production-production/"
  }

  policy = "${data.aws_iam_policy_document.communications_bucket_policy_document.json}"
}

# Documents - jenkins: read write list

data "aws_iam_policy_document" "documents_bucket_policy_document" {
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
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-documents-production-production/*",
      "arn:aws:s3:::digitalmarketplace-documents-production-production",
    ]
  }
}

resource "aws_s3_bucket" "documents_bucket" {
  bucket = "digitalmarketplace-documents-production-production"
  acl    = "private"

  versioning {
    enabled    = true
    mfa_delete = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-documents-production-production/"
  }

  policy = "${data.aws_iam_policy_document.documents_bucket_policy_document.json}"
}

# G7-draft-documents

resource "aws_s3_bucket" "g7-draft-documents_bucket" {
  bucket = "digitalmarketplace-g7-draft-documents-production-production"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-g7-draft-documents-production-production/"
  }
}

# Submissions - jenkins: read list

data "aws_iam_policy_document" "submissions_bucket_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"]
      type        = "AWS"
    }

    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-submissions-production-production/*",
      "arn:aws:s3:::digitalmarketplace-submissions-production-production",
    ]
  }
}

resource "aws_s3_bucket" "submissions_bucket" {
  bucket = "digitalmarketplace-submissions-production-production"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.server_access_logs_bucket.id}"
    target_prefix = "digitalmarketplace-submissions-production-production/"
  }

  policy = "${data.aws_iam_policy_document.submissions_bucket_policy_document.json}"
}
