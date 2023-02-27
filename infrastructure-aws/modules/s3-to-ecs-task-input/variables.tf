variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "process_name" {
  type        = string
  description = "Short name for the process facilitated by this module - used in resource naming"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}
