resource "aws_iam_role" "ecs_deployment_jenkins_role" {
  name               = "${var.project_name}-${var.environment_name}-ecs-deployment-jenkins-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_deployment_jenkins_role_policy.json
}

resource "aws_iam_policy" "ecs_service_deployment_policy" {
  name   = "${var.project_name}-${var.environment_name}-ecs-service-deployment-policy"
  policy = data.aws_iam_policy_document.ecs_service_deployment_policy.json
}

resource "aws_iam_policy" "jenkins_role_terraform_state_policy" {
  name   = "${var.project_name}-${var.environment_name}-jenkins-role-terraform-state-policy"
  policy = data.aws_iam_policy_document.jenkins_role_terraform_state_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_deployment_jenkins_role_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_service_deployment_policy.arn
  role       = aws_iam_role.ecs_deployment_jenkins_role.id
}

resource "aws_iam_role_policy_attachment" "jenkins_role_terraform_state_policy_attachment" {
  policy_arn = aws_iam_policy.jenkins_role_terraform_state_policy.arn
  role       = aws_iam_role.ecs_deployment_jenkins_role.id
}

data "aws_iam_policy_document" "ecs_service_deployment_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:CreateService"
    ]

    resources = [
      "arn:aws:ecs:${var.aws_region}:${var.aws_target_account}:service/${var.project_name}-${var.environment_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_deployment_jenkins_role_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.jenkins_account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "jenkins_role_terraform_state_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_s3_bucket_name}",
      "arn:aws:s3:::${var.terraform_state_s3_bucket_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem"
    ]

    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${var.aws_target_account}:table/${var.terraform_state_dynamodb_table_name}"
    ]
  }
}
