variable "egress_all_security_group_id" {
  type        = string
  description = "ID of the securty group which allows all egress"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "lambda_bucket_id" {
  type        = string
  description = "Full name of bucket through which to provide Lambda deployments"
}

variable "process_name" {
  type        = string
  description = "Short name for the process facilitated by this module - used in resource naming"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of each of the private subnets"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
