module "cloudtrail" {
  source              = "../../modules/cloudtrail"
  account_id          = "${var.aws_dev_account_id}"
  s3_bucket_name      = "digitalmarketplaces-dev-account-cloudtrail-bucket"
  trail_name          = "digitalmarketplaces-dev-account-cloudtrail"
}
