output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = module.digitalmarketplace_full.apprunner_build_iam_role_arn
}
