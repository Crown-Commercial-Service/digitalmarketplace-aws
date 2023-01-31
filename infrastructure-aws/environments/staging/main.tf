module "digitalmarketplace_full" {
  source = "../../compositions/digitalmarketplace-full"

  ecr_repo_name_buyer_frontend = var.ecr_repo_name_buyer_frontend
  environment_name             = var.environment_name
  project_name                 = var.project_name
}
