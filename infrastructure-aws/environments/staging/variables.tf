variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
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
  type        = map(number)
  description = "Desired number of instances for each service"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}

variable "vpc_private_subnets_cidr_blocks" {
  type        = map(string)
  description = "CIDR blocks for private subnets"
}

variable "vpc_public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for public subnet"
}
