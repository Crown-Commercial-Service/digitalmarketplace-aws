module "digitalmarketplace_full" {
  source = "../../compositions/digitalmarketplace-full"

  environment_name = var.environment_name
  project_name     = var.project_name
}
