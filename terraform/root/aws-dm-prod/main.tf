module "aws_env" {
  source = "../../modules/aws-env"
  whitelisted_ips = "${var.whitelisted_ips}"
  aws_main_account_id = "${var.aws_main_account_id}"
}
