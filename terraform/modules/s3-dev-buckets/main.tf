module "agreements" {
  source = "s3-bucket"
  aws_main_account_id = "${var.aws_main_account_id}"
  s3_bucket_name = "agreements"
}

module "communications" {
  source = "s3-bucket"
  aws_main_account_id = "${var.aws_main_account_id}"
  s3_bucket_name = "communications"
}

module "documents" {
  source = "s3-bucket"
  aws_main_account_id = "${var.aws_main_account_id}"
  s3_bucket_name = "documents"
}

module "submissions" {
  source = "s3-bucket"
  aws_main_account_id = "${var.aws_main_account_id}"
  s3_bucket_name = "submissions"
}
