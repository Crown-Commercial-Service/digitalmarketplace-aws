variable "admin_users" {
  type = "list"
}
variable "developer_users" {
  type = "list"
}
variable "basic_users" {
  type = "list"
}
variable "ip_restricted_access_policy_arn" {}
variable "mfa_restricted_access_policy_arn" {}
variable "iam_manage_account_policy_arn" {}
variable "developer_policy_arn" {}
variable "aws_dev_account_id" {}
variable "aws_prod_account_id" {}
variable "switch_to_dev_developer_users" {
  type = "list"
}
variable "switch_to_prod_developer_users" {
  type = "list"
}
variable "switch_to_dev_s3_only_users" {
  type = "list"
}
