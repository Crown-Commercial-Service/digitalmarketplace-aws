variable "admins" {
  type = list(string)
}

variable "backups" {
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

variable "ip_restricted_access_policy_arn" {
}

variable "iam_manage_account_policy_arn" {
}

variable "admin_policy_arn" {
}

variable "aws_dev_account_id" {
}

variable "aws_backups_account_id" {
}

variable "aws_prod_account_id" {
}

variable "security_audit_users" {
  type = list(string)
}
