provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-production"
    key     = "environments/staging/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "staging_router" {
  source = "../../modules/router"
  name   = "staging-router"

  domain = "staging.marketplace.team"

  log_retention_days = "180"

  cname_domain              = "d316z22457q6mz.cloudfront.net"
  www_acme_challenge        = "gAvnidL435OgRSEbsmaRao8t6h556S7pR579scyWidY"
  api_acme_challenge        = "PnHbLO52oob6u-vDm1oLuO6eYA6jhZNSPZHRAwkPQSk"
  search_api_acme_challenge = "CBejAeUi-c-88fyngXwAd9Q45ivBiPqbXm4wnD9-7nY"
  assets_acme_challenge     = "qHoJDoj_Fckc061F_DZ7BhQRhMv4EV3BYZ9hKGoew84"
}

module "application_logs" {
  source = "../../modules/application-logs"

  environment       = "staging"
  retention_in_days = "180"
}

module "log_streaming" {
  source = "../../modules/log-streaming"

  name                  = "staging-log-stream-lambda"
  elasticsearch_url     = "${var.logs_elasticsearch_url}"
  elasticsearch_api_key = "${var.logs_elasticsearch_api_key}"

  nginx_log_groups       = ["${concat(module.staging_router.json_log_groups, module.application_logs.nginx_log_groups)}"]
  application_log_groups = ["${module.application_logs.application_log_groups}"]
}

module "log_metrics" {
  source                               = "../../modules/logging/log-metric-filters"
  environment                          = "staging"
  app_names                            = ["${module.application_logs.app_names}"]
  router_log_group_name                = "${element(module.staging_router.json_log_groups, 0)}"
  antivirus_sns_failure_log_group_name = "${module.antivirus-sns.failure_log_group_name}"
  antivirus_sns_success_log_group_name = "${module.antivirus-sns.success_log_group_name}"
  antivirus_sns_topic_num_retries      = "${module.antivirus-sns.topic_num_retries}"
}

module "antivirus-sns" {
  source                   = "../../modules/antivirus-sns"
  environment              = "staging"
  account_id               = "${var.aws_prod_account_id}"
  antivirus_api_host       = "${var.antivirus_api_host}"
  antivirus_api_basic_auth = "${var.antivirus_api_basic_auth}"
  retention_in_days        = "180"
  log_stream_lambda_arn    = "${module.log_streaming.log_stream_lambda_arn}"

  bucket_ids = [
    "${aws_s3_bucket.agreements_bucket.id}",
    "${aws_s3_bucket.communications_bucket.id}",
    "${aws_s3_bucket.documents_bucket.id}",
  ]
}
