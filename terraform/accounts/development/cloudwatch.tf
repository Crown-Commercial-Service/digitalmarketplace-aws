module "cloudtrail" {
  source              = "../../modules/cloudtrail"
  aws_main_account_id = "${var.aws_main_account_id}"
  s3_bucket_name      = "digitalmarketplaces-dev-account-cloudtrail-bucket"
  trail_name          = "digitalmarketplaces-dev-account-cloudtrail"
}
