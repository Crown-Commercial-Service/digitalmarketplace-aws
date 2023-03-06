output "read_repo_policy_document_json" {
  description = "JSON describing an IAM policy which allows read access to this ECR repo"
  value       = data.aws_iam_policy_document.read_repo.json
}

output "repo_url" {
  description = "URL of this EPR repo"
  value       = aws_ecr_repository.repo.repository_url
}
