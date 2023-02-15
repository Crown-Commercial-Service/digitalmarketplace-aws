module "dmp_vpc" {
  source = "../../resource-groups/public-private-vpc"

  environment_name              = var.environment_name
  project_name                  = var.project_name
  vpc_cidr_block                = var.vpc_cidr_block
  vpc_private_subnet_cidr_block = var.vpc_private_subnet_cidr_block
  vpc_public_subnet_cidr_block  = var.vpc_public_subnet_cidr_block
}
