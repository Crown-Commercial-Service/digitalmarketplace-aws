resource "aws_s3_bucket" "database_backups_s3_bucket" {
  bucket = "digitalmarketplace-database-backups"
  acl    = "private"

  versioning {
    enabled    = true
    mfa_delete = true
  }
}
