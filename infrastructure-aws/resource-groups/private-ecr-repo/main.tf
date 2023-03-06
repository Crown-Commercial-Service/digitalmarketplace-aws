resource "aws_ecr_repository" "repo" {
  name = "${var.project_name}/${var.service_name}"
}

data "aws_iam_policy_document" "read_repo" {
  version = "2012-10-17"

  statement {
    sid = "GetAuthorizationToken" # Deliberately named so that identical statements overwrite each other

    actions = [
      "ecr:GetAuthorizationToken"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }

  statement {
    sid = "Read${replace(var.service_name, "-", "")}EcrRepo"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer"
    ]
    effect = "Allow"
    resources = [
      aws_ecr_repository.repo.arn
    ]
  }
}
