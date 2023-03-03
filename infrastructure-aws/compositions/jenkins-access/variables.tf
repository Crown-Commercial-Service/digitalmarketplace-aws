variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "aws_target_account" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "jenkins_account_id" {
  type        = string
  description = "The Account ID of the Jenkins instance from which ECS will perform deployments"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "terraform_state_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket holding the Terraform State file"
}

variable "terraform_state_dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table holding the Lock files for the Terraform State"
}
