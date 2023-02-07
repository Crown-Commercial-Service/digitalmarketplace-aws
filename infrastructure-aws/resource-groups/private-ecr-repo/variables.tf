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
  description = "Name of the service which is based on this repo"
}
