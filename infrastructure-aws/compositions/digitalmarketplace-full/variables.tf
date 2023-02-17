variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "aws_target_account" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "domain_name" {
  type        = string
  description = "Domain name to use in public-facing ingress cert and URL"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of the Route 53 Hosted Zone which will manage the DNS and cert validation for this environment"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "services_desired_counts" {
  type        = map(any)
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

variable "vpc_public_subnets_cidr_blocks" {
  type        = map(string)
  description = "CIDR blocks for public subnets"
}
