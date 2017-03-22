provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "digitalmarketplace-terraform-state-production"
    key = "accounts/production/terraform.tfstate"
    region = "eu-west-1"
    encrypt =  "true"
  }
}

module "aws_env" {
  source = "../../modules/aws-env"
  whitelisted_ips = "${var.whitelisted_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id = "${var.aws_dev_account_id}"
}
