output "aws_iam_policy_developer_arn" {
  value = "${aws_iam_policy.developer.arn}"
}
output "aws_iam_policy_ip_restricted_access_arn" {
  value = "${aws_iam_policy.ip_restricted_access.arn}"
}
output "aws_iam_policy_mfa_restricted_access_arn" {
  value = "${aws_iam_policy.mfa_restricted_access.arn}"
}
output "aws_iam_policy_iam_manage_account_arn" {
  value = "${aws_iam_policy.iam_manage_account.arn}"
}
