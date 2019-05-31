module "cloudtrail" {
  source              = "../../modules/cloudtrail"
  account_id          = "${var.aws_main_account_id}"
  s3_bucket_name      = "digitalmarketplaces-main-account-cloudtrail-bucket"
  trail_name          = "digitalmarketplaces-main-account-cloudtrail"
}
