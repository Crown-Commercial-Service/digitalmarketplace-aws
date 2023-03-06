variable "api_clients_security_group_id" {
  type        = string
  description = "ID of security group allowing access to the API ALB"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "aws_target_account" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "container_command" {
  type        = list(string)
  description = "Command to run as container task (as array)"
  sensitive   = true # Likely contains API tokens etc
}

variable "container_environment_variables" {
  type        = list(map(string))
  description = "List of maps defining environment variables"
}

variable "container_memory" {
  type        = number
  description = "Memory to allocate to each task container (where a value of 1024 == 1GB)"
}

variable "ecr_repo_url" {
  type        = string
  description = "URL of the ECR repo containing the image from which to create task containers"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which service is to be deplyed"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

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

variable "pass_ecs_execution_role_policy_arn" {
  type        = string
  description = "ARN of policy permitting passsage of the ECS execution role"
}

variable "process_name" {
  type        = string
  description = "Short name for the process facilitated by this module - used in resource naming"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "secret_environment_variables" {
  type        = list(map(string))
  description = "List of maps defining environment variables derived from secrets"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of subnets into which to place resources and tasks"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
