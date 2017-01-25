variable "whitelisted_ips" {
  type = "list"
}

variable "admin_users" {
  type = "list"
}

variable "developer_users" {
  type = "list"
}

variable "ansible_users" {
  type = "list"
}

variable "terraform_users" {
  type = "list"
}

variable "packer_users" {
  type = "list"
}

variable "sops_credentials_access_policy_arn" {}
