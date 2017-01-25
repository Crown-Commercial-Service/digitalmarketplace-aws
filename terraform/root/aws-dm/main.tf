module "sops_credentials" {
  source = "../../modules/sops-credentials"
}

module "iam" {
  source = "../../modules/iam"
  whitelisted_ips = "${var.whitelisted_ips}"
  admin_users = "${var.admin_users}"
  developer_users = "${var.developer_users}"
  ansible_users = "${var.ansible_users}"
  terraform_users = "${var.terraform_users}"
  packer_users = "${var.packer_users}"
  sops_credentials_access_policy_arn = "${module.sops_credentials.aws_iam_policy_sops_credentials_access_arn}"
}
