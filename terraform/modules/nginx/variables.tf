variable "name" {}
variable "environment" {}
variable "domain" {}

variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}

variable "instance_count" {}
variable "min_instance_count" {}
variable "max_instance_count" {}
variable "instance_type" {}

variable "ssh_key_name" {}

variable "ami_owner_account_id" {}

variable "admin_user_ips" {
  type = "list"
}
variable "dev_user_ips" {
  type = "list"
}
variable "user_ips" {
  type = "list"
}

variable "log_retention_days" {}

variable "g7_draft_documents_s3_url" {}
variable "documents_s3_url" {}
variable "agreements_s3_url" {}
variable "communications_s3_url" {}
variable "submissions_s3_url" {}

variable "api_url" {}
variable "search_api_url" {}
variable "frontend_url" {}

variable "app_auth" {}

variable "mode" {}
