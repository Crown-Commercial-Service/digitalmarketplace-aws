resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = "${length(var.bucket_ids)}"
  bucket = "${var.bucket_ids[count.index]}"

  topic {
    topic_arn = "${aws_sns_topic.s3_file_upload_notification.arn}"
    events    = ["s3:ObjectCreated:*"]
  }
}
