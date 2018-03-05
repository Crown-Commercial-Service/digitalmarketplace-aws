variable "aws_main_account_id" {}

variable "aws_sub_account_ids" {
  type = "list"
}
variable "jenkins_security_group_ids" {
  type = "list"
}
variable "jenkins_2_key_name" {}
variable "jenkins_2_public_key" {}
