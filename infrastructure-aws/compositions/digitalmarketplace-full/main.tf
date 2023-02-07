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

module "buyer_frontend_service" {
  source = "../../modules/single-apprunner-service"

  apprunner_build_role_name = aws_iam_role.apprunner_build.name
  environment_name          = var.environment_name
  project_name              = var.project_name
  service_name              = "buyer-frontend"
}
