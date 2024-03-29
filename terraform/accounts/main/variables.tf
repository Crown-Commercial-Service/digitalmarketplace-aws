variable "ssh_key_name" {
}

variable "jenkins_public_key" {
}

variable "aws_account_and_jenkins_login_ips" {
  type = list(string)
}

variable "aws_main_account_id" {
}

variable "aws_sub_account_ids" {
  type = list(string)
}

variable "aws_dev_account_id" {
}

variable "aws_sandbox_account_id" {
}

variable "aws_staging_account_id" {
}

variable "aws_backups_account_id" {
}

variable "aws_prod_account_id" {
}

variable "csw_agent_account_id" {
}

variable "gds_security_audit_chain_account_id" {
}

variable "admins" {
  type = list(string)
}

variable "developers" {
  type = list(string)
}

variable "prod_developers" {
  type = list(string)
}

variable "dev_s3_only_users" {
  type = list(string)
}

variable "dev_infrastructure_users" {
  type = list(string)
}

variable "prod_infrastructure_users" {
  type = list(string)
}

variable "security_audit_users" {
  type = list(string)
}
