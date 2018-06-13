provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-development"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-development"
    key     = "accounts/development/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "aws_env" {
  source              = "../../modules/aws-env"
  dev_user_ips        = "${var.dev_user_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id  = "${var.aws_dev_account_id}"
}
