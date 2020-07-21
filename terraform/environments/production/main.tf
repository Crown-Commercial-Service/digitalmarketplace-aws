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
    bucket  = "digitalmarketplace-terraform-state-production"
    key     = "environments/production/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "production_router" {
  source = "../../modules/router"
  name   = "production-router"

  domain = "digitalmarketplace.service.gov.uk"

  log_retention_days = "3653"

  cname_domain              = "d3pp9vxqezcjw2.cloudfront.net"
  www_acm_value             = "_2533026340ed4b4a24b09340fedc85d5.jfrzftwwjs.acm-validations.aws."
  www_acm_name              = "_f8537f5176fa0132541cc64978203785.www."
  api_acm_value             = "_a716cce694fa6f137f0b635d2d99e640.jfrzftwwjs.acm-validations.aws."
  api_acm_name              = "_cd4d4ebc88b211a33f49a7bfbec4153c.api."
  search_api_acm_value      = "_43a6fa789628598d9d54032cf6b0275a.jfrzftwwjs.acm-validations.aws."
  search_api_acm_name       = "_f6f4c3316e1f46a83a398775af242e71.search-api."
  assets_acm_value          = "_1e1ff1759e34e6e56f7000e46eba51a2.jfrzftwwjs.acm-validations.aws."
  assets_acm_name           = "_a504b430ba24d9f975df4d5677fa5683.assets."
  antivirus_api_acm_value   = "_a2c38fdc747637add5b6ff0958fe5141.jfrzftwwjs.acm-validations.aws."
  antivirus_api_acm_name    = "_c304f7f525b21772de85e239fc32df96.antivirus-api."
}

module "application_logs" {
  source = "../../modules/log-groups"

  environment       = "production"
  retention_in_days = "3653"
}

module "log_streaming" {
  source = "../../modules/log-streaming"

  name                  = "production-log-stream-lambda"
  elasticsearch_url     = "${var.logs_elasticsearch_url}"
  elasticsearch_api_key = "${var.logs_elasticsearch_api_key}"

  nginx_log_groups       = ["${concat(module.production_router.json_log_groups, module.application_logs.nginx_log_groups)}"]
  application_log_groups = ["${module.application_logs.application_log_groups}"]
}

module "log_metrics" {
  source                               = "../../modules/logging/log-metric-filters"
  environment                          = "production"
  app_names                            = ["${module.application_logs.app_names}"]
  router_log_group_name                = "${element(module.production_router.json_log_groups, 0)}"
  antivirus_sns_failure_log_group_name = "${module.antivirus-sns.failure_log_group_name}"
  antivirus_sns_success_log_group_name = "${module.antivirus-sns.success_log_group_name}"
  antivirus_sns_topic_num_retries      = "${module.antivirus-sns.topic_num_retries}"
}

module "antivirus-sns" {
  source                   = "../../modules/antivirus-sns"
  environment              = "production"
  account_id               = "${var.aws_prod_account_id}"
  antivirus_api_host       = "${var.antivirus_api_host}"
  antivirus_api_basic_auth = "${var.antivirus_api_basic_auth}"
  retention_in_days        = "3653"
  log_stream_lambda_arn    = "${module.log_streaming.log_stream_lambda_arn}"

  bucket_arns = [
    "${aws_s3_bucket.agreements_bucket.arn}",
    "${aws_s3_bucket.communications_bucket.arn}",
    "${aws_s3_bucket.documents_bucket.arn}",
    "${aws_s3_bucket.submissions_bucket.arn}",
  ]
}
