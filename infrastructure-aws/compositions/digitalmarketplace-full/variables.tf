variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "jenkins_account_id" {
  type        = string
  description = "The Account ID of the Jenkins instance from which AppRunner will perform deployments"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
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
