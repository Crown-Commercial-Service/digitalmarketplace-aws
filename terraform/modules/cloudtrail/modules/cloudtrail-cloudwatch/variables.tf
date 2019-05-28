variable "trail_name" {
  description = "The name of the CloudTrail trail we are setting up CloudWatch for."
}

variable "retention_in_days" {
  default     = 731
  description = "Days to keep CloudTrail log events in CloudWatch"
}
