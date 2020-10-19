output "aws_iam_policy_ip_restricted_access_arn" {
  value = aws_iam_policy.ip_restricted_access.arn
}

output "aws_iam_policy_admin_arn" {
  value = aws_iam_policy.admin.arn
}

output "aws_iam_policy_iam_manage_account_arn" {
  value = aws_iam_policy.iam_manage_account.arn
}

output "aws_iam_policy_infrastructure_arn" {
  value = aws_iam_role.infrastructure.arn
}

