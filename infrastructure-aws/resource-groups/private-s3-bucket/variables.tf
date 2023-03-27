variable "bucket_name" {
  type        = string
  description = "Name to give the S3 bucket (must be globally unique)"
}

variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "versioning" {
  type        = bool
  description = "If set to true, will activate versioning on all objects placed in the bucket"
  default     = false
}
