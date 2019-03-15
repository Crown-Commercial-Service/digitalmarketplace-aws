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

module "csw_inspector_role" {
  source                = "git::https://github.com/alphagov/csw-client-role.git?ref=v1.0"
  csw_agent_account_id  = "${var.csw_agent_account_id}"
  csw_target_account_id = "${var.aws_backups_account_id}"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-backups"
    key     = "accounts/backups/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}
