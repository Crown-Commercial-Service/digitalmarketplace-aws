output "read_repo_iam_policy_arn" {
  description = "The ARN of the policy granting read access to the ECR repo"
  value       = aws_iam_policy.read_repo.arn
}
