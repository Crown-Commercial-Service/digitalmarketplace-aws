resource "aws_s3_bucket" "cross_region_database_backups_s3_bucket" {
  provider = "aws.london"
  bucket   = "digitalmarketplace-cross-region-database-backups"
  acl      = "private"
  region   = "eu-west-2"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_backups_account_id}:role/backups"},
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-database-backups"
    },
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_backups_account_id}:role/backups"},
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-database-backups/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "database_backups_s3_bucket" {
  bucket = "digitalmarketplace-database-backups"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = 180
    }
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_backups_account_id}:role/backups"},
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups"
    },
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_backups_account_id}:role/backups"},
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups/*"
    },
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"},
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups"
    },
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_main_account_id}:role/jenkins-ci-IAMRole-1FIPDG9DE2CWJ"},
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups/*"
    }
  ]
}
POLICY

  replication_configuration {
    role = "${aws_iam_role.replication_role.arn}"

    rules {
      prefix = "*"
      status = "Enabled"

      destination {
        bucket = "${aws_s3_bucket.cross_region_database_backups_s3_bucket.arn}"
      }
    }
  }
}
