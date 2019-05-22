# Cross Region replication buckets
resource "aws_s3_bucket" "cross_region_documents_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-documents-preview-preview"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cross_region_documents_s3_bucket" {
  bucket = "${aws_s3_bucket.cross_region_documents_s3_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-documents-preview-preview/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "cross_region_agreements_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-agreements-preview-preview"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cross_region_agreements_s3_bucket" {
  bucket = "${aws_s3_bucket.cross_region_agreements_s3_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-agreements-preview-preview/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "cross_region_communications_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-communications-preview-preview"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cross_region_communications_s3_bucket" {
  bucket = "${aws_s3_bucket.cross_region_communications_s3_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-communications-preview-preview/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "cross_region_submissions_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-submissions-preview-preview"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cross_region_submissions_s3_bucket" {
  bucket = "${aws_s3_bucket.cross_region_submissions_s3_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-submissions-preview-preview/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}
