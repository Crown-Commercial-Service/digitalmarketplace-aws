variable "trail_name" {
  description = "(Required) A name for the trail we are creating. https://www.terraform.io/docs/providers/aws/r/cloudtrail.html#name"
}

variable "s3_bucket_name" {
  description = "(Required) The s3 bucket we should put the CloudTrail logs in. https://www.terraform.io/docs/providers/aws/r/cloudtrail.html#s3_bucket_name"
}

variable "s3_bucket_key_prefix" {
  default     = ""
  description = "Prefix that  https://www.terraform.io/docs/providers/aws/r/cloudtrail.html#s3_key_prefix"
}

variable "cloud_watch_logs_group_arn" {
  default     = ""
  description = "CloudWatch log group arn. https://www.terraform.io/docs/providers/aws/r/cloudtrail.html#cloud_watch_logs_group_arn"
}

variable "cloud_watch_logs_role_arn" {
  default     = ""
  description = "IAM Role for writing to log group. https://www.terraform.io/docs/providers/aws/r/cloudtrail.html#cloud_watch_logs_role_arn"
}
