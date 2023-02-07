resource "aws_ecr_repository" "repo" {
  name = "${var.project_name}/${var.service_name}"
}

resource "aws_iam_policy" "read_repo" {
  name = "${var.project_name}-${var.environment_name}-ecr-repo-${var.service_name}-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer"
        ],
        Effect = "Allow",
        Resource = [
          aws_ecr_repository.repo.arn
        ]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
