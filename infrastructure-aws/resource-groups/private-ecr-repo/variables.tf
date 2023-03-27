variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "service_name" {
  type        = string
  description = "Name of the service which is based on this repo"
}
