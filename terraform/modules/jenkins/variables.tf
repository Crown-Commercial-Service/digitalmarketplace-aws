variable "aws_main_account_id" {}

variable "aws_sub_account_ids" {
  type = "list"
}

variable "dev_user_ips" {
  type = "list"
}

variable "jenkins_public_key_name" {}
variable "jenkins_public_key" {}
