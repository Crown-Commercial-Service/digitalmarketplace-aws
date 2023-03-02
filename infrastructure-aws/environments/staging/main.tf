module "digitalmarketplace_full" {
  source = "../../compositions/digitalmarketplace-full"

  aws_region                      = var.aws_region
  aws_target_account              = data.aws_caller_identity.current.account_id
  domain_name                     = var.domain_name
  environment_name                = var.environment_name
  hosted_zone_id                  = var.hosted_zone_id
  project_name                    = var.project_name
  services_desired_counts         = var.services_desired_counts
  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_private_subnets_cidr_blocks = var.vpc_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks  = var.vpc_public_subnets_cidr_blocks
}

module "jenkins_access" {
  source                              = "../../compositions/jenkins-access"
  aws_region                          = var.aws_region
  aws_target_account                  = data.aws_caller_identity.current.account_id
  environment_name                    = var.environment_name
  jenkins_account_id                  = var.jenkins_account_id
  project_name                        = var.project_name
  terraform_state_dynamodb_table_name = var.terraform_state_dynamodb_table_name
  terraform_state_s3_bucket_name      = var.terraform_state_s3_bucket_name
}
