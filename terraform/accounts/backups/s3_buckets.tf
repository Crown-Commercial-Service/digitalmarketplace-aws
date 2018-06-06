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
      "Principal": {"AWS": "arn:aws:iam::${var.aws_prod_account_id}:role/infrastructure"},
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups"
    },
    {
      "Principal": {"AWS": "arn:aws:iam::${var.aws_prod_account_id}:role/infrastructure"},
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
}
