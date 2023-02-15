variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "aws_target_account" {
  type = string
  description = "ID of the account into which deployments are performed"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "services_desired_counts" {
  type = map
  description = "Desired number of instances for each service"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}

variable "vpc_private_subnet_cidr_block" {
  type        = string
  description = "CIDR block for private subnet"
}

variable "vpc_public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for public subnet"
}
