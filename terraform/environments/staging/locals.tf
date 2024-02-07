locals {
  antivirus_api_host       = data.aws_ssm_parameter.antivirus_api_host.value
  antivirus_api_basic_auth = data.aws_ssm_parameter.antivirus_api_basic_auth.value
  aws_main_account_id      = data.aws_ssm_parameter.aws_main_account_id.value
  aws_prod_account_id      = data.aws_caller_identity.current.account_id
  bucket_names = {
    agreements = {
      name               = "digitalmarketplace-agreements-staging"
      source_bucket_name = "digitalmarketplace-agreements-staging-staging"
      source_region      = "eu-west-1"
    }
    communications = {
      name               = "digitalmarketplace-communications-staging"
      source_bucket_name = "digitalmarketplace-communications-staging-staging"
      source_region      = "eu-west-1"
    }
    documents = {
      name               = "digitalmarketplace-documents-staging"
      source_bucket_name = "digitalmarketplace-documents-staging-staging"
      source_region      = "eu-west-1"
    }
    g7-draft-documents = {
      name               = "digitalmarketplace-g7-draft-documents-staging"
      source_bucket_name = "digitalmarketplace-g7-draft-documents-staging-staging"
      source_region      = "eu-west-1"
    }
    logs = {
      name               = "digitalmarketplace-logs-staging"
      source_bucket_name = "digitalmarketplace-logs-staging-staging"
      source_region      = "eu-west-1"
    }
    reports = {
      name               = "digitalmarketplace-reports-staging"
      source_bucket_name = "digitalmarketplace-reports-staging-staging"
      source_region      = "eu-west-1"
    }
    submissions = {
      name               = "digitalmarketplace-submissions-staging"
      source_bucket_name = "digitalmarketplace-submissions-staging-staging"
      source_region      = "eu-west-1"
    }
  }
  logs_elasticsearch_url     = data.aws_ssm_parameter.logs_elasticsearch_url.value
  logs_elasticsearch_api_key = data.aws_ssm_parameter.logs_elasticsearch_api_key.value
  resource_name_prefixes = {
    normal        = "XDN:EUW2:SBX",
    hyphens       = "XDN-EUW2-SBX",
    hyphens_lower = "xdn-euw2-sbx",
  }
}
