variable "name" {}
variable "environment" {}

variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}

variable "instance_count" {}
variable "min_instance_count" {}
variable "max_instance_count" {}
variable "instance_type" {}

variable "ssh_key_name" {}

variable "ami_owner_account_id" {}

variable "log_retention_days" {}

variable "elasticsearch_port" {
  type = "string"
  default = "9200"
}

variable "nginx_security_group_id" {}
