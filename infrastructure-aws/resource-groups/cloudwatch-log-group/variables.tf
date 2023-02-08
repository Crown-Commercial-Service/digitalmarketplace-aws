variable "log_group_name" {
  type        = string
  description = "Name for this log group"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days for which to retain log entries"
  default     = 30
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}
