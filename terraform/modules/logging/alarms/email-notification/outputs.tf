output "email_topic_arn" {
  value = "${aws_sns_topic.alarm_email_topic.arn}"
}
