module "iam_common" {
  source              = "../../modules/iam-common"
  dev_user_ips        = "${var.dev_user_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
  aws_dev_account_id  = "${var.aws_dev_account_id}"
}

module "paas" {
  source = "../../modules/paas"
}
