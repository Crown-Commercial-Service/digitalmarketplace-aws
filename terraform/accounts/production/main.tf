provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-production"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-production"
    key     = "accounts/production/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "iam_common" {
  source              = "../../modules/iam-common"
  dev_user_ips        = "${var.dev_user_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id  = "${var.aws_dev_account_id}"
}

module "switch_roles" {
  source                          = "../../modules/switch-roles"
  ip_restricted_access_policy_arn = "${module.iam_common.aws_iam_policy_ip_restricted_access_arn}"
  iam_manage_account_policy_arn   = "${module.iam_common.aws_iam_policy_iam_manage_account_arn}"
  aws_main_account_id             = "${var.aws_main_account_id}"
}

module "paas" {
  source = "../../modules/paas"
}

# TODO remove old csw_inspector_role in favour of new gds_security_audit_role when switch to new role  is completed by secops

module "csw_inspector_role" {
  source               = "git::https://github.com/alphagov/csw-client-role.git?ref=v1.2"
  csw_agent_account_id = "${var.csw_agent_account_id}"
}

module "gds_security_audit_role" {
  source           = "git::https://github.com/alphagov/tech-ops.git?ref=13f54e5//cyber-security/modules/gds_security_audit_role"
  chain_account_id = "${var.gds_security_audit_chain_account_id}"
}
