resource "aws_iam_role" "apprunner_build" {
  name = "${var.project_name}-${var.environment_name}-apprunner-build-service"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "apprunner_service_deployment_policy" {
  name   = "${var.project_name}-${var.environment_name}-apprunner-service-deployment-policy"
  policy = data.aws_iam_policy_document.apprunner_service_deployment_policy.json
}

resource "aws_iam_role" "apprunner_deployment_jenkins_role" {
  name                = "${var.project_name}-${var.environment_name}-apprunner-deployment-jenkins-role"
  assume_role_policy  = data.aws_iam_policy_document.apprunner_deployment_jenkins_role_policy.json
}

resource "aws_iam_role_policy_attachment" "apprunner_deployment_jenkins_role_policy_attachment" {
  policy_arn = aws_iam_policy.apprunner_service_deployment_policy.arn
  role       = aws_iam_role.apprunner_deployment_jenkins_role.id
}

module "dmp_vpc" {
  source = "../../resource-groups/public-private-vpc"

  environment_name              = var.environment_name
  project_name                  = var.project_name
  vpc_cidr_block                = var.vpc_cidr_block
  vpc_private_subnet_cidr_block = var.vpc_private_subnet_cidr_block
  vpc_public_subnet_cidr_block  = var.vpc_public_subnet_cidr_block
}

module "buyer_frontend_service" {
  source = "../../modules/single-apprunner-service"

  apprunner_build_role_name = aws_iam_role.apprunner_build.name
  environment_name          = var.environment_name
  project_name              = var.project_name
  service_name              = "buyer-frontend"
}
