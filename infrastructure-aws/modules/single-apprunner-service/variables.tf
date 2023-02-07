variable "apprunner_build_role_name" {
  type        = string
  description = "Name of the IAM role which AppRunner Build will assume during service creation"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "service_name" {
  type        = string
  description = "Name of this service"
}
