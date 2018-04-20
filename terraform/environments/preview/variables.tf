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
variable "frontend_url" {}

variable "app_auth" {}

variable "logs_elasticsearch_url" {}
variable "logs_elasticsearch_api_key" {}
