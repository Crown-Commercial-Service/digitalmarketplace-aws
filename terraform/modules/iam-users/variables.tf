variable "admins" {
  type = "list"
}
variable "developers" {
  type = "list"
}
variable "dev_developers" {
  type = "list"
}
variable "prod_developers" {
  type = "list"
}
variable "dev_s3_only_users" {
  type = "list"
}

variable "ip_restricted_access_policy_arn" {}
variable "iam_manage_account_policy_arn" {}
variable "developer_policy_arn" {}
variable "admin_policy_arn" {}
variable "aws_dev_account_id" {}
variable "aws_prod_account_id" {}
