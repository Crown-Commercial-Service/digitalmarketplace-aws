provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

provider "aws" {
  alias   = "london"
  region  = "eu-west-2"
  version = "1.9.0"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-backups"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-backups"
    key     = "accounts/backups/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}
