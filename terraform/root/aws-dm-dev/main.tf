provider "aws" {
  region = "eu-west-1"
}

module "aws_env" {
  source = "../../modules/aws-env"
  whitelisted_ips = "${var.whitelisted_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id = "${var.aws_dev_account_id}"
}

module "s3-bucket" {
  source = "../../modules/s3-bucket"
  access_account_id = "${var.aws_main_account_id}"
  bucket_name = "digitalmarketplace-dev-uploads"
}
