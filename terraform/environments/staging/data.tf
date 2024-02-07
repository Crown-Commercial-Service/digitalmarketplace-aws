data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

data "aws_ssm_parameter" "antivirus_api_host" {
  name = var.ssm_param_antivirus_api_host
}

data "aws_ssm_parameter" "antivirus_api_basic_auth" {
  name = var.ssm_param_antivirus_api_basic_auth
}

data "aws_ssm_parameter" "logs_elasticsearch_url" {
  name = var.ssm_param_logs_elasticsearch_url
}

data "aws_ssm_parameter" "logs_elasticsearch_api_key" {
  name = var.ssm_param_logs_elasticsearch_api_key
}

data "aws_ssm_parameter" "aws_main_account_id" {
  name = var.ssm_param_aws_main_account_id
}
