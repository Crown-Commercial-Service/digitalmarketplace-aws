provider "aws" {
  region  = "eu-west-1"
  version = "1.9.0"
}

provider "aws" {
  alias   = "london"
  region  = "eu-west-2"
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

  cname_domain            = "d25mxit1hgdj3z.cloudfront.net"
  www_acm_value           = "_d3502b7f8e8375277e10b2a7a5c5184f.tfmgdnztqk.acm-validations.aws."
  www_acm_name            = "_d3fce2c248a4041784f06c22a0090865.assets."
  api_acm_value           = "_bd3d82c6197b75e9ab21e7a60512f7ef.tfmgdnztqk.acm-validations.aws."
  api_acm_name            = "_588eb18af3dc5d8581c483bd3df00607.api."
  search_api_acm_value    = "_64f5fb82d733c1d2222e4aa64a03b037.tfmgdnztqk.acm-validations.aws."
  search_api_acm_name     = "_652fee20b56f7182234ee35cf8cbbc3e.search-api."
  assets_acm_value        = "_67847da8bf05e8175ebfdf514f34cd3f.tfmgdnztqk.acm-validations.aws."
  assets_acm_name         = "_d3fce2c248a4041784f06c22a0090865.assets."
  antivirus_api_acm_value = "_304c9698a6caf6522fd7c0f8c1f3f206.tfmgdnztqk.acm-validations.aws."
  antivirus_api_acm_name  = "_e9bbdc88aebdbb1753eb4c81fd7cf1b9.antivirus-api."
}

module "application_logs" {
  source = "../../modules/log-groups"

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
  source                               = "../../modules/logging/log-metric-filters"
  environment                          = "preview"
  app_names                            = ["${module.application_logs.app_names}"]
  router_log_group_name                = "${element(module.preview_router.json_log_groups, 0)}"
  antivirus_sns_failure_log_group_name = "${module.antivirus-sns.failure_log_group_name}"
  antivirus_sns_success_log_group_name = "${module.antivirus-sns.success_log_group_name}"
  antivirus_sns_topic_num_retries      = "${module.antivirus-sns.topic_num_retries}"
}

module "antivirus-sns" {
  source                   = "../../modules/antivirus-sns"
  environment              = "preview"
  account_id               = "${var.aws_dev_account_id}"
  antivirus_api_host       = "${var.antivirus_api_host}"
  antivirus_api_basic_auth = "${var.antivirus_api_basic_auth}"
  retention_in_days        = "180"
  log_stream_lambda_arn    = "${module.log_streaming.log_stream_lambda_arn}"

  bucket_arns = [
    "${aws_s3_bucket.agreements_bucket.arn}",
    "${aws_s3_bucket.communications_bucket.arn}",
    "${aws_s3_bucket.submissions_bucket.arn}",
  ]
}
