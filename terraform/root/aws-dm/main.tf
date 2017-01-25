module "iam_common" {
  source = "../../modules/iam-common"
  whitelisted_ips = "${var.whitelisted_ips}"
}

module "iam_users" {
  source = "../../modules/iam-users"
  admin_users = "${var.admin_users}"
  developer_users = "${var.developer_users}"
  basic_users = "${var.basic_users}"
  ip_restricted_access_policy_arn = "${module.iam_common.aws_iam_policy_ip_restricted_access_arn}"
  mfa_restricted_access_policy_arn = "${module.iam_common.aws_iam_policy_mfa_restricted_access_arn}"
  iam_manage_account_policy_arn = "${module.iam_common.aws_iam_policy_iam_manage_account_arn}"
  developer_policy_arn = "${module.iam_common.aws_iam_policy_developer_arn}"
  aws_dev_account_id = "${var.aws_dev_account_id}"
  aws_prod_account_id = "${var.aws_prod_account_id}"
  switch_to_dev_developer_users = "${var.switch_to_dev_developer_users}"
  switch_to_prod_developer_users = "${var.switch_to_prod_developer_users}"
  switch_to_dev_s3_only_users = "${var.switch_to_dev_s3_only_users}"
}

module "sops_credentials" {
  source = "../../modules/sops-credentials"
  # Make sure you update the count here (see https://github.com/hashicorp/terraform/issues/1497 for more info)
  sops_credentials_access_iam_groups_count = 1
  sops_credentials_access_iam_groups = [
    "${module.iam_users.developers_group_name}"
  ]
  aws_account_ids = "${concat(list(var.aws_main_account_id), var.aws_sub_account_ids)}"
}
