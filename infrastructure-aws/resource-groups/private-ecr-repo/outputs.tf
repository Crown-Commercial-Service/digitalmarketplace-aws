output "read_repo_iam_policy_arn" {
  description = "The ARN of the policy granting read access to this ECR repo"
  value       = aws_iam_policy.read_repo.arn
}

output "repo_url" {
  description = "URL of this EPR repo"
  value       = aws_ecr_repository.repo.repository_url
}
