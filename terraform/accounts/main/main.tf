provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
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
  developer_policy_arn            = "${module.iam_common.aws_iam_policy_developer_arn}"
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

module "jenkins" {
  source                     = "../../modules/jenkins"
  aws_main_account_id        = "${var.aws_main_account_id}"
  aws_sub_account_ids        = "${var.aws_sub_account_ids}"
  jenkins_security_group_ids = "${var.jenkins_security_group_ids}"
  jenkins_public_key       = "${var.jenkins_public_key}"
}
