module "aws_env" {
  source = "../../modules/aws-env"
  whitelisted_ips = "${var.whitelisted_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id = "${var.aws_dev_account_id}"
}

module "s3_dev_buckets" {
  source = "../../modules/s3-dev-buckets"
  aws_main_account_id = "${var.aws_main_account_id}"
}
