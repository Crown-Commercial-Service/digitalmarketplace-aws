module "digitalmarketplace_full" {
  source = "../../compositions/digitalmarketplace-full"

  aws_region                    = var.aws_region
  environment_name              = var.environment_name
  jenkins_account_id            = var.jenkins_account_id
  project_name                  = var.project_name
  vpc_cidr_block                = var.vpc_cidr_block
  vpc_private_subnet_cidr_block = var.vpc_private_subnet_cidr_block
  vpc_public_subnet_cidr_block  = var.vpc_public_subnet_cidr_block
}
