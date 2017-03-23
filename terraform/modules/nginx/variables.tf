variable "name" {}
variable "environment" {}
variable "domain" {}

variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}

variable "ssl_cert_arn" {}

variable "instance_count" {}
variable "min_instance_count" {
  default = "${var.instance_count}"
}
variable "max_instance_count" {
  default = "${var.instance_count}"
}
variable "instance_type" {}

variable "ssh_key_name" {}

variable "ami_owner_account_id" {}

variable "admin_user_ips" {}
variable "dev_user_ips" {}

variable "log_retention_days" {}

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
variable "elasticsearch_url" {}

variable "elasticsearch_auth" {}
variable "app_auth" {}
