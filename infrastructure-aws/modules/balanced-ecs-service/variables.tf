variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "aws_target_account" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "container_environment_variables" {
  type        = list(map(string))
  description = "Environment variables to be made available to service container tasks"
}

variable "container_healthcheck_proxy_credentials" {
  type        = string
  description = "Basic auth credentials to enable on-container curl-based healthchecks"
  sensitive   = true
  default     = null
}

variable "container_memory" {
  type        = number
  description = "Memory to allocate to each task container (where a value of 1024 == 1GB)"
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

variable "egress_all_security_group_id" {
  type        = string
  description = "ID of security group allowing all egress"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "lb_target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer Target Group with which instances of this service should register"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}

variable "secret_environment_variables" {
  type        = list(map(string))
  description = "Environment variables to be looked up as secrets and then made available to each task container"
  default     = []
}

variable "service_name" {
  type        = string
  description = "Name of the service, indicating its purpose"
}

variable "service_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets in which to run the ECS tasks"
}

variable "target_group_security_group_id" {
  type        = string
  description = "Identifies the holder as a routable target for its upstream Load Balancer"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
