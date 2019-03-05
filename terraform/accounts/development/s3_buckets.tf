data "aws_iam_policy_document" "dev_uploads_s3_bucket_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:root"]
      type        = "AWS"
    }

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-dev-uploads",
    ]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:root"]
      type        = "AWS"
    }

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-dev-uploads/*",
    ]
  }
}

resource "aws_s3_bucket" "dev_uploads_s3_bucket" {
  bucket = "digitalmarketplace-dev-uploads"
  acl    = "private"

  policy = "${data.aws_iam_policy_document.dev_uploads_s3_bucket_policy_document.json}"
}

data "aws_iam_policy_document" "cleaned_db_dumps_s3_bucket_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:root"]
      type        = "AWS"
    }

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cleaned-db-dumps",
    ]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${var.aws_main_account_id}:root"]
      type        = "AWS"
    }

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cleaned-db-dumps/*",
    ]
  }
}

resource "aws_s3_bucket" "cleaned_db_dumps_s3_bucket" {
  bucket = "digitalmarketplace-cleaned-db-dumps"
  acl    = "private"

  policy = "${data.aws_iam_policy_document.cleaned_db_dumps_s3_bucket_policy_document.json}"
}
