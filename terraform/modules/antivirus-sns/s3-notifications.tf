resource "aws_s3_bucket_notification" "bucket_notification" {
  count = "${length(var.bucket_arns)}"

  // Bucket identifiers are passed as arns but we require just 'id'/name here
  bucket = "${replace(var.bucket_arns[count.index], "arn:aws:s3:::", "")}"

  topic {
    topic_arn = "${aws_sns_topic.s3_file_upload_notification.arn}"
    events    = ["s3:ObjectCreated:*"]
  }
}
