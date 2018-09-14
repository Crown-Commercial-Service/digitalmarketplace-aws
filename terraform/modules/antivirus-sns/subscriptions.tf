resource "aws_sns_topic_subscription" "antivirus_to_s3_file_upload_notification_topic" {
  topic_arn              = "${aws_sns_topic.s3_file_upload_notification.arn}"
  protocol               = "https"
  endpoint               = "https://${var.antivirus_api_basic_auth}@${var.antivirus_api_host}/callbacks/sns/s3/uploaded"
  endpoint_auto_confirms = "true"
}
