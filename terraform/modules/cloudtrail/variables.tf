variable "account_id" {
  description = "The ID of the account, used as the S3 bucket key prefix"
}

variable "s3_bucket_name" {}

variable "trail_name" {}

variable "validate_account_id" {
  description = "The ID of the account that can assume the role for validating logs"
}
