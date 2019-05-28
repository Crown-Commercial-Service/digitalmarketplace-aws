module "cloudtrail-bucket" {
  source         = "./modules/cloudtrail-bucket"
  s3_bucket_name = "${var.s3_bucket_name}"
}

module "cloudtrail-cloudwatch" {
  source            = "./modules/cloudtrail-cloudwatch"
  trail_name        = "${var.trail_name}"
  retention_in_days = 731                               // As per RE convention on keeping logs for 2 years
}

module "cloudtrail-cloudtrail" {
  source                     = "./modules/cloudtrail-cloudtrail"
  trail_name                 = "${var.trail_name}"
  s3_bucket_name             = "${var.s3_bucket_name}"
  s3_bucket_key_prefix       = "${var.aws_main_account_id}"
  cloud_watch_logs_role_arn  = "${module.cloudtrail-cloudwatch.cloud_watch_logs_role_arn}"
  cloud_watch_logs_group_arn = "${module.cloudtrail-cloudwatch.cloud_watch_logs_group_arn}"
}
