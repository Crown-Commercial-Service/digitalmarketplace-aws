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

# TODO remove old csw_inspector_role in favour of new gds_security_audit_role when switch to new role  is completed by secops

module "csw_inspector_role" {
  source               = "git::https://github.com/alphagov/csw-client-role.git?ref=v1.2"
  csw_agent_account_id = "${var.csw_agent_account_id}"
}

module "gds_security_audit_role" {
  source           = "git::https://github.com/alphagov/tech-ops.git?ref=c363ba6//cyber-security/modules/gds_security_audit_role"
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
