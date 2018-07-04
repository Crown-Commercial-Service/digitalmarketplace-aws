module "gds-audit-cloudtrail" {
  source               = "../../modules/cloudtrail/cloudtrail"
  trail_name           = "digitalmarketplace-gds-audit-cloudtrail"
  s3_bucket_name       = "gds-audit-cloudtrails"                   // This is currently the name of the RE bucket being used to log GDS sub accounts
  s3_bucket_key_prefix = "${var.aws_main_account_id}"              // As per RE guidelines this should be the id of the account exporting the CloudTrail trail log files
}

module "cloudtrail-bucket" {
  source         = "../../modules/cloudtrail/cloudtrail-bucket"
  s3_bucket_name = "digitalmarketplaces-main-account-cloudtrail-bucket"
}

module "cloudtrail-cloudwatch" {
  source            = "../../modules/cloudtrail/cloudtrail-cloudwatch"
  trail_name        = "digitalmarketplace-main-account-cloudtrail"
  retention_in_days = 731                                              // As per RE convention on keeping logs for 2 years
}

module "cloudtrail" {
  source                     = "../../modules/cloudtrail/cloudtrail"
  trail_name                 = "digitalmarketplaces-main-account-cloudtrail"
  s3_bucket_name             = "${module.cloudtrail-bucket.s3_bucket_name}"
  s3_bucket_key_prefix       = "${var.aws_main_account_id}"
  cloud_watch_logs_role_arn  = "${module.cloudtrail-cloudwatch.cloud_watch_logs_role_arn}"
  cloud_watch_logs_group_arn = "${module.cloudtrail-cloudwatch.cloud_watch_logs_group_arn}"
}
