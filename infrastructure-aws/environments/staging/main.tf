module "lambda_deployment_bucket" {
  source       = "../../resource-groups/private-s3-bucket"
  bucket_name  = "${var.project_name}-${var.environment_name}-lambda-deployment"
  is_ephemeral = var.environment_is_ephemeral
}

module "digitalmarketplace_full" {
  source = "../../compositions/digitalmarketplace-full"

  aws_region                      = var.aws_region
  aws_target_account              = data.aws_caller_identity.current.account_id
  domain_name                     = var.domain_name
  environment_is_ephemeral        = var.environment_is_ephemeral
  environment_name                = var.environment_name
  hosted_zone_id                  = var.hosted_zone_id
  lambda_bucket_id                = module.lambda_deployment_bucket.bucket_id
  project_name                    = var.project_name
  services_container_memories     = var.services_container_memories
  services_desired_counts         = var.services_desired_counts
  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_private_subnets_cidr_blocks = var.vpc_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks  = var.vpc_public_subnets_cidr_blocks

  depends_on = [
    data.archive_file.lambda_zip
  ]
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
