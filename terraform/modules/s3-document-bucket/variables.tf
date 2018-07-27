variable "bucket_name" {
  description = "(Required) A name our S3 bucket, will be formetted like 'digitalmarketplace-{bucket_name}-{environment}-{environment}'."
}

variable "environment" {
  description = "(Required) A suffix for our S3 bucket, see above."
}

variable "log_bucket_name" {
  description = "(Required) A bucket to log access requests to."
}

variable "read_object_roles" {
  type        = "list"
  description = "A list of role ARNs to apply get object permssions to."
}

variable "write_object_roles" {
  type        = "list"
  description = "A list of role ARNs to apply S3:PutObject and S3:PutObjectACL permissions to."
}

variable "list_bucket_roles" {
  type        = "list"
  description = "A list of role ARNs to give S3ListBucket and S3:ListBucketLocation to."
}
