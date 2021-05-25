terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38.0"
    }

    archive = {
      version = "~> 1.3"
    }
  }
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

  cname_domain            = "d316z22457q6mz.cloudfront.net"
  www_acm_value           = "_a4da5eba3aafdf9678deaa24a883eb7f.jfrzftwwjs.acm-validations.aws."
  www_acm_name            = "_1d240148b08ff53cf23f086a0ede70d0.www."
  api_acm_value           = "_da88346b4df90d2f48f5325214f4eefa.jfrzftwwjs.acm-validations.aws."
  api_acm_name            = "_931290d183ce63092cf3a11a27c829d1.api."
  search_api_acm_value    = "_ce105f953286c5abeb4119857ef8be0d.jfrzftwwjs.acm-validations.aws."
  search_api_acm_name     = "_bcc5b347135144bac6efcc6b43fe5b4b.search-api."
  assets_acm_value        = "_b610609289861ce0b0b91b86f87ecfcd.jfrzftwwjs.acm-validations.aws."
  assets_acm_name         = "_d1566e76f4f310932de01dc91651f590.assets."
  antivirus_api_acm_value = "_b60218e4087dbd3ca9082994dfaa380a.jfrzftwwjs.acm-validations.aws."
  antivirus_api_acm_name  = "_3a55f25136ea0e61591ff87ec05181a0.antivirus-api."
}

module "application_logs" {
  source = "../../modules/log-groups"

  environment       = "staging"
  retention_in_days = "180"
}

module "log_streaming" {
  source = "../../modules/log-streaming"

  name                  = "staging-log-stream-lambda"
  elasticsearch_url     = var.logs_elasticsearch_url
  elasticsearch_api_key = var.logs_elasticsearch_api_key

  nginx_log_groups = concat(
    module.staging_router.json_log_groups,
    module.application_logs.nginx_log_groups,
  )
  application_log_groups = module.application_logs.application_log_groups
}

module "log_metrics" {
  source                               = "../../modules/logging/log-metric-filters"
  environment                          = "staging"
  app_names                            = module.application_logs.app_names
  router_log_group_name                = element(module.staging_router.json_log_groups, 0)
  antivirus_sns_failure_log_group_name = module.antivirus-sns.failure_log_group_name
  antivirus_sns_success_log_group_name = module.antivirus-sns.success_log_group_name
  antivirus_sns_topic_num_retries      = module.antivirus-sns.topic_num_retries
}

module "antivirus-sns" {
  source                   = "../../modules/antivirus-sns"
  environment              = "staging"
  account_id               = var.aws_prod_account_id
  antivirus_api_host       = var.antivirus_api_host
  antivirus_api_basic_auth = var.antivirus_api_basic_auth
  retention_in_days        = "180"
  log_stream_lambda_arn    = module.log_streaming.log_stream_lambda_arn

  bucket_arns = [
    aws_s3_bucket.agreements_bucket.arn,
    aws_s3_bucket.communications_bucket.arn,
    aws_s3_bucket.documents_bucket.arn,
    aws_s3_bucket.submissions_bucket.arn,
  ]
}

