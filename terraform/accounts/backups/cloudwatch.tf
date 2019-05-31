module "cloudtrail" {
  source              = "../../modules/cloudtrail"
  account_id          = "${var.aws_backups_account_id}"
  s3_bucket_name      = "digitalmarketplaces-backups-account-cloudtrail-bucket"
  trail_name          = "digitalmarketplaces-backups-account-cloudtrail"
}
