resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.trail_name}"
  s3_bucket_name                = "${var.s3_bucket_name}"
  s3_key_prefix                 = "${var.s3_bucket_key_prefix}"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${var.cloud_watch_logs_group_arn}"
  cloud_watch_logs_role_arn     = "${var.cloud_watch_logs_role_arn}"
}
