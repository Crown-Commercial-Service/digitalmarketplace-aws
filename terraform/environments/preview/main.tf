provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

terraform {
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-development"
    key     = "environments/preview/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "preview_router" {
  source = "../../modules/router"
  name   = "preview-router"

  domain = "preview.marketplace.team"

  log_retention_days = "180"

  cname_domain              = "d3eyi6749eogkv.cloudfront.net"
  www_acme_challenge        = "10BxG5sYBrsXy9nTFn4U2dn90v0ic7yFGkf5egYYzvM"
  api_acme_challenge        = "dTEB4iW45IMydD38YUCjjwtbaX1V-tXki-J1dZ4IIK4"
  search_api_acme_challenge = "mn-kwBxpLeqkLBenVhQYZIoX02iIaMPaAiYw1ndiKy4"
  assets_acme_challenge     = "nml3dVZaOkLIUql5v6rxPb-vHy2PoXbJ6oFGzMB8SrY"
}

module "application_logs" {
  source = "../../modules/application-logs"

  environment       = "preview"
  retention_in_days = "180"
}

module "log_streaming" {
  source = "../../modules/log-streaming"

  name                  = "preview-log-stream-lambda"
  elasticsearch_url     = "${var.logs_elasticsearch_url}"
  elasticsearch_api_key = "${var.logs_elasticsearch_api_key}"

  nginx_log_groups       = ["${concat(module.preview_router.json_log_groups, module.application_logs.nginx_log_groups)}"]
  application_log_groups = ["${module.application_logs.application_log_groups}"]
}

module "log_metrics" {
  source                = "../../modules/log-metrics"
  environment           = "preview"
  app_names             = ["${module.application_logs.app_names}"]
  router_log_group_name = "${element(module.preview_router.json_log_groups, 0)}"
}

module "antivirus-sns" {
  source                   = "../../modules/antivirus-sns"
  environment              = "preview"
  account_id               = "${var.aws_dev_account_id}"
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
