provider "aws" {
  region = "eu-west-1"
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

module "iam_common" {
  source                            = "../../modules/iam-common"
  aws_account_and_jenkins_login_ips = var.aws_account_and_jenkins_login_ips
  aws_main_account_id               = var.aws_main_account_id
  aws_dev_account_id                = var.aws_dev_account_id
}

module "switch_roles" {
  source                          = "../../modules/switch-roles"
  ip_restricted_access_policy_arn = module.iam_common.aws_iam_policy_ip_restricted_access_arn
  iam_manage_account_policy_arn   = module.iam_common.aws_iam_policy_iam_manage_account_arn
  aws_main_account_id             = var.aws_main_account_id
}

module "paas" {
  source = "../../modules/paas"
}

module "gds_security_audit_role" {
  source           = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=720885a9769c40942ff30b32179e1fad18f2ca10"
  chain_account_id = var.gds_security_audit_chain_account_id
}

