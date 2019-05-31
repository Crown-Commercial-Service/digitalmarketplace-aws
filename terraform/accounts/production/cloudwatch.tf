module "cloudtrail" {
  source              = "../../modules/cloudtrail/cloudtrail"
  aws_main_account_id = "${var.aws_main_account_id}"
  s3_bucket_name      = "digitalmarketplace-prod-account-cloudtrail-bucket"
  trail_name          = "digitalmarketplaces-prod-account-cloudtrail"
}
