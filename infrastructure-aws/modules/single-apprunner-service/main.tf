module "ecr_repo" {
  source = "../../resource-groups/private-ecr-repo"

  environment_name = var.environment_name
  project_name     = var.project_name
  service_name     = var.service_name
}

resource "aws_iam_role_policy_attachment" "apprunner_build__read_ecr" {
  role       = var.apprunner_build_role_name
  policy_arn = module.ecr_repo.read_repo_iam_policy_arn
}
