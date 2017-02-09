output "aws_kms_key_sops_credentials_primary_arn" {
  value = "${aws_kms_key.sops_credentials_primary.arn}"
}

output "aws_kms_key_sops_credentials_secondary_arn" {
  value = "${aws_kms_key.sops_credentials_secondary.arn}"
}

output "aws_iam_role_sops_credentials_access_arn" {
  value = "${aws_iam_role.sops_credentials_access.arn}"
}
