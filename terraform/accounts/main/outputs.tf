output "aws_kms_key_sops_credentials_primary_arn" {
  value = module.sops_credentials.aws_kms_key_sops_credentials_primary_arn
}

output "aws_kms_key_sops_credentials_secondary_arn" {
  value = module.sops_credentials.aws_kms_key_sops_credentials_secondary_arn
}

output "aws_iam_role_sops_credentials_access_arn" {
  value = module.sops_credentials.aws_iam_role_sops_credentials_access_arn
}

