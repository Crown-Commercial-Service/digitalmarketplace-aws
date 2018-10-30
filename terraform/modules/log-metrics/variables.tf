variable "environment" {}

variable "app_names" {
  type = "list"
}

variable "router_log_group_name" {}

variable "antivirus_sns_failure_log_group_name" {}
variable "antivirus_sns_success_log_group_name" {}
variable "antivirus_sns_topic_num_retries" {}
