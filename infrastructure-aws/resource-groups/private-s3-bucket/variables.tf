variable "bucket_name" {
  type        = string
  description = "Name to give the S3 bucket (must be globally unique)"
}

variable "versioning" {
  type        = bool
  description = "If set to true, will activate versioning on all objects placed in the bucket"
  default     = false
}
