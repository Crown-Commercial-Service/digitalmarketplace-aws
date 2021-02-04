variable "account_id" {
}

variable "environment" {
}

variable "bucket_arns" {
  type = list(string)
}

variable "antivirus_api_host" {
}

variable "antivirus_api_basic_auth" {
}

variable "retention_in_days" {
}

variable "log_stream_lambda_arn" {
}

variable "topic_num_retries" {
  default = 5
}

