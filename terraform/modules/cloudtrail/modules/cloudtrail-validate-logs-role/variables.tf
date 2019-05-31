variable "assume_role_arn" {
  description = "The ARN of the account that can assume this role"
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket where CloudTrail logs are stored"
}
