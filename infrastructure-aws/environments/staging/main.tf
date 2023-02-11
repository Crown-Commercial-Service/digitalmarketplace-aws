module "digitalmarketplace_full" {
  source = "../../compositions/digitalmarketplace-full"

  environment_name              = var.environment_name
  project_name                  = var.project_name
  vpc_cidr_block                = var.vpc_cidr_block
  vpc_private_subnet_cidr_block = var.vpc_private_subnet_cidr_block
  vpc_public_subnet_cidr_block  = var.vpc_public_subnet_cidr_block
}
