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
  www_acme_challenge        = "6R2Srug_clrhWCdEv-BXP9bbZY88cBSk_d5B9CFaiDM"
  api_acme_challenge        = "eovwGgagiCUwdb-NlbZndlV6JIukpZtK2MJQcXtb5ec"
  search_api_acme_challenge = "6BF1gcDwKfuLc_xCP1Se8PIjXjL8Ayk8QFgDxqsX8qw"
  assets_acme_challenge     = "qFDTBZVXxuuaMqgm1c-D5wX4iRJogcnTEaJdhDSG-rw"
}

module "application_logs" {
  source = "../../modules/application-logs"

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

  bucket_ids = [
    "${aws_s3_bucket.agreements_bucket.id}",
    "${aws_s3_bucket.communications_bucket.id}",
    "${aws_s3_bucket.documents_bucket.id}",
  ]
}
