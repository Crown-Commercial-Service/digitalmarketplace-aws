locals {
  aws_main_account_id        = data.aws_ssm_parameter.aws_main_account_id.value
  aws_prod_account_id        = data.aws_caller_identity.current.account_id
  antivirus_api_host         = data.aws_ssm_parameter.antivirus_api_host.value
  antivirus_api_basic_auth   = data.aws_ssm_parameter.antivirus_api_basic_auth.value
  logs_elasticsearch_url     = data.aws_ssm_parameter.logs_elasticsearch_url.value
  logs_elasticsearch_api_key = data.aws_ssm_parameter.logs_elasticsearch_api_key.value
}
