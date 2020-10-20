provider "aws" {
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "london"
  region  = "eu-west-2"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-backups"
}

module "cyber_security_audit_role" {
  source = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=720885a9769c40942ff30b32179e1fad18f2ca10"
  chain_account_id = "${var.gds_security_audit_chain_account_id}"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-backups"
    key     = "accounts/backups/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}
