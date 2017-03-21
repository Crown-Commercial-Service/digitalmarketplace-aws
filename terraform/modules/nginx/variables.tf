variable "name" {}
variable "environment" {}

variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}

variable "ssl_cert_arn" {}

variable "instance_count" {}
variable "min_instance_count" {}
variable "max_instance_count" {}
variable "instance_type" {}

variable "ssh_key_name" {}

variable "ami_owner_account_id" {}

variable "admin_user_ips" {}
variable "dev_user_ips" {}

variable "log_group_name" {}
variable "json_log_group_name" {}

variable "assets_subdomain" {}
variable "api_subdomain" {}
variable "search_api_subdomain" {}
variable "www_subdomain" {}

variable "g7_draft_documents_s3_url" {}
variable "documents_s3_url" {}
variable "agreements_s3_url" {}
variable "communications_s3_url" {}
variable "submissions_s3_url" {}

variable "api_url" {}
variable "search_api_url" {}
variable "buyer_frontend_url" {}
variable "admin_frontend_url" {}
variable "supplier_frontend_url" {}
