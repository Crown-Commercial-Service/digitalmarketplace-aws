variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "aws_target_account" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "desired_count" {
  type        = number
  description = "Target number of instances of service to run (fixed)"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of cluster into which service is to be deplyed"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role which is assumed by the ECS execution processes"
}

variable "ecs_execution_role_name" {
  type        = string
  description = "Name of the role which is assumed by the ECS execution processes"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "fake_api_url" {
  type = string
  description = "URL of stub API to assist startup of service (temporary)"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "service_name" {
  type        = string
  description = "Name of the service, indicating its purpose"
}

variable "service_security_group_ids" {
  type        = list(string)
  description = "IDs of the security groups which are to be assigned to the running ECS tasks"
}

variable "service_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets in which to run the ECS tasks"
}

variable "session_cache_nodes" {
  type        = list(map(string))
  description = "Node endpoints for session cache"
}