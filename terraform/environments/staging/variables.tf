variable "aws_main_account_id" {}
variable "admin_user_ips" {
  type = "list"
}
variable "dev_user_ips" {
  type = "list"
}
variable "user_ips" {
  type = "list"
}

variable "ssh_key_name" {}

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

variable "elasticsearch_auth" {}
variable "app_auth" {}

variable "nginx_config" {
  default = "live"
}
