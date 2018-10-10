# Cross Region replication buckets
resource "aws_s3_bucket" "cross_region_documents_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-documents-production"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "cross_region_agreements_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-agreements-production"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "cross_region_communications_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-communications-production"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "cross_region_submissions_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-submissions-production"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }
}
