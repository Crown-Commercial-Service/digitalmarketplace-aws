variable "jenkins_ip" {}

variable "jenkins_security_group_ids" {
  type = "list"
}

variable "jenkins_public_key" {}

variable "dev_user_ips" {
  type = "list"
}

variable "aws_main_account_id" {}

variable "aws_sub_account_ids" {
  type = "list"
}

variable "aws_dev_account_id" {}
variable "aws_backups_account_id" {}
variable "aws_prod_account_id" {}

variable "admins" {
  type = "list"
}

variable "developers" {
  type = "list"
}

variable "prod_developers" {
  type = "list"
}

variable "dev_s3_only_users" {
  type = "list"
}

variable "dev_infrastructure_users" {
  type = "list"
}

variable "prod_infrastructure_users" {
  type = "list"
}
