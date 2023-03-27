variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "file_system_config" {
  type        = map(string)
  description = "Map of config values for a Lambda file system attachment, as set out in the `file_system_config` argument for a Lambda function"
  default     = null
}

variable "function_base_name" {
  type        = string
  description = "The base name to give to the Lambda function (without prefixes etc)"
}

variable "handler" {
  type        = string
  description = "Name of the handler to invoke in the format `module.exportedname`"
  default     = "index.handler"
}

variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "lambda_bucket_id" {
  type        = string
  description = "The name of the bucket via which to deploy"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days for which to keep log entries from this lambda"
  default     = 30
}

variable "runtime" {
  type        = string
  description = "Runtime library for this Lambda"
  default     = "python3.9"
}

variable "runtime_memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  default     = 128
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of IDs of the security groups to assign to this Lambda"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of each of the subnets in which to place this Lambda"
}

variable "timeout_seconds" {
  type        = number
  description = "The number of seconds to wait for a response from the Lambda"
  default     = 15
}
