module "cloudtrail-bucket" {
  source         = "../../modules/cloudtrail/cloudtrail-bucket"
  s3_bucket_name = "digitalmarketplaces-dev-account-cloudtrail-bucket"
}

module "cloudtrail-cloudwatch" {
  source            = "../../modules/cloudtrail/cloudtrail-cloudwatch"
  trail_name        = "digitalmarketplace-dev-account-cloudtrail"
  retention_in_days = 731                                              // As per RE convention on keeping logs for 2 years
}

module "cloudtrail" {
  source                     = "../../modules/cloudtrail/cloudtrail"
  trail_name                 = "digitalmarketplaces-dev-account-cloudtrail"
  s3_bucket_name             = "${module.cloudtrail-bucket.s3_bucket_name}"
  s3_bucket_key_prefix       = "${var.aws_dev_account_id}"
  cloud_watch_logs_role_arn  = "${module.cloudtrail-cloudwatch.cloud_watch_logs_role_arn}"
  cloud_watch_logs_group_arn = "${module.cloudtrail-cloudwatch.cloud_watch_logs_group_arn}"
}
