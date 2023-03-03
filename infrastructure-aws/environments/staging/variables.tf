variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
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

variable "jenkins_account_id" {
  type        = string
  description = "The Account ID of the Jenkins instance from which ECS will perform deployments"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "services_container_memories" {
  type        = map(number)
  description = "Memory to allocate to task containers for each service (where a value of 1024 == 1GB)"
}

variable "services_desired_counts" {
  type        = map(number)
  description = "Desired number of instances for each service"
}

variable "terraform_state_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket holding the Terraform State file"
}

variable "terraform_state_dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table holding the Lock files for the Terraform State"
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
