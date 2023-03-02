resource "aws_iam_policy" "read_secrets" {
  name = "${var.project_name}-read-secrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${var.aws_target_account}:secret:${var.project_name}-${var.environment_name}-*"
        ]
      }
    ]
  })
}

# Secrets read at startup - Execution role needs access (rather than task role)
resource "aws_iam_role_policy_attachment" "read_secrets" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.read_secrets.arn
}
