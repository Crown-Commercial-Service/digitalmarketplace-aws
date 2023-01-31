variable "ecr_repo_name_buyer_frontend" {
  type        = string
  description = "ECR Repository name for the Buyer Frontend service"
}

variable "environment_name" {
  type        = string
  description = "Name to indicate purpose of environment"
}

variable "project_name" {
  type        = string
  description = "Namespace to prepend to resource names where hierarchy is required"
}
