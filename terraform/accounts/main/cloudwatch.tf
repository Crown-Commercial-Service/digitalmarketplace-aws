module "cloudtrail" {
  source              = "../../modules/cloudtrail"
  account_id          = "${var.aws_main_account_id}"
  s3_bucket_name      = "digitalmarketplace-main-account-cloudtrail-bucket"
  trail_name          = "digitalmarketplace-main-account-cloudtrail"
  validate_account_id = "${var.aws_main_account_id}"
}
