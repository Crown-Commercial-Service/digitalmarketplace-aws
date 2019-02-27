variable "environment" {}
variable "type" {}
variable "alarm_email_topic_arn" {}
variable "alarm_recovery_email_topic_arn" {}

variable "app_names" {
  type = "list"
}
