provider "aws" {
  region  = "eu-west-1"
  version = "~> 1.60.0"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-main"
    key     = "accounts/main/terraform.tfstate"
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

module "iam_users" {
  source                          = "../../modules/iam-users"
  admins                          = "${var.admins}"
  backups                         = "${var.prod_infrastructure_users}"                             // Add prod_infrastructure_users to backups group, gives 2nd line access to backups
  developers                      = "${var.developers}"
  dev_s3_only_users               = "${var.dev_s3_only_users}"
  prod_developers                 = "${var.prod_developers}"
  dev_infrastructure_users        = "${var.dev_infrastructure_users}"
  prod_infrastructure_users       = "${var.prod_infrastructure_users}"
  ip_restricted_access_policy_arn = "${module.iam_common.aws_iam_policy_ip_restricted_access_arn}"
  iam_manage_account_policy_arn   = "${module.iam_common.aws_iam_policy_iam_manage_account_arn}"
  admin_policy_arn                = "${module.iam_common.aws_iam_policy_admin_arn}"
  aws_dev_account_id              = "${var.aws_dev_account_id}"
  aws_backups_account_id          = "${var.aws_backups_account_id}"
  aws_prod_account_id             = "${var.aws_prod_account_id}"
}

module "sops_credentials" {
  source = "../../modules/sops-credentials"

  # Make sure you update the count here (see https://github.com/hashicorp/terraform/issues/1497 for more info)
  sops_credentials_access_iam_groups_count = 1

  sops_credentials_access_iam_groups = [
    "${module.iam_users.developers_group_name}",
  ]

  aws_account_ids = "${concat(list(var.aws_main_account_id), var.aws_sub_account_ids)}"
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
