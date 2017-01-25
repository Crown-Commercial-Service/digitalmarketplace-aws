variable "whitelisted_ips" {
  type = "list"
}

variable "aws_main_account_id" {}
variable "aws_sub_account_ids" {
  type = "list"
}
variable "aws_dev_account_id" {}
variable "aws_prod_account_id" {}

variable "admin_users" {
  type = "list"
}
variable "developer_users" {
  type = "list"
}
variable "basic_users" {
  type = "list"
}
variable "switch_to_dev_developer_users" {
  type = "list"
}
variable "switch_to_prod_developer_users" {
  type = "list"
}
variable "switch_to_dev_s3_only_users" {
  type = "list"
}
