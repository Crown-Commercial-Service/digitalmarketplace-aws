module "ecr_repo" {
  source = "../../resource-groups/private-ecr-repo"

  environment_name = var.environment_name
  is_ephemeral     = var.is_ephemeral
  project_name     = var.project_name
  service_name     = var.service_name
}
