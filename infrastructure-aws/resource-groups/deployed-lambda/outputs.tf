output "function_arn" {
  description = "ARN of the deployed function"
  value       = aws_lambda_function.function.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "invoke_lambda_iam_policy_arn" {
  description = "ARN of the IAM Policy which allows invocation of this Lambda"
  value       = aws_iam_policy.invoke_lambda.arn
}

output "service_role_name" {
  description = "Name of the service role assigned to this Lambda"
  value       = aws_iam_role.lambda_exec.name
}
