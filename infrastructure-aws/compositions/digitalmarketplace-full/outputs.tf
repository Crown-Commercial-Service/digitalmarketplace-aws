output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = aws_iam_role.apprunner_build.arn
}
