provider "aws" {
  region  = "eu-west-1"
}

module "cloudtrail-bucket" {
  source         = "./modules/cloudtrail-bucket"
  s3_bucket_name = var.s3_bucket_name
}

module "cloudtrail-cloudwatch" {
  source            = "./modules/cloudtrail-cloudwatch"
  trail_name        = var.trail_name
  retention_in_days = 731 // As per RE convention on keeping logs for 2 years
}

module "cloudtrail-validate-logs-role" {
  source          = "./modules/cloudtrail-validate-logs-role"
  assume_role_arn = "arn:aws:iam::${var.validate_account_id}:root"
  s3_bucket_arn   = module.cloudtrail-bucket.s3_bucket_arn
}

module "cloudtrail-cloudtrail" {
  source                     = "./modules/cloudtrail-cloudtrail"
  trail_name                 = var.trail_name
  s3_bucket_name             = var.s3_bucket_name
  s3_bucket_key_prefix       = var.account_id
  cloud_watch_logs_role_arn  = module.cloudtrail-cloudwatch.cloud_watch_logs_role_arn
  cloud_watch_logs_group_arn = module.cloudtrail-cloudwatch.cloud_watch_logs_group_arn
}

