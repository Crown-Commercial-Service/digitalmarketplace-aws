module "dmp_vpc" {
  source = "../../resource-groups/public-private-vpc"

  aws_region                      = var.aws_region
  environment_name                = var.environment_name
  project_name                    = var.project_name
  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_private_subnets_cidr_blocks = var.vpc_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks  = var.vpc_public_subnets_cidr_blocks
}
