variable "account_id" {}
variable "environment" {}

variable "bucket_ids" {
  type = "list"
}

variable "antivirus_api_host" {}
variable "antivirus_api_basic_auth" {}

variable "retention_in_days" {}
variable "log_stream_lambda_arn" {}
