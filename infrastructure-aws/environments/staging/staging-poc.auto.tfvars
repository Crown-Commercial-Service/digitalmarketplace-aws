aws_region       = "eu-west-1"
domain_name      = "dmp.mcbhenwood.com" # Temporary
environment_name = "staging"
hosted_zone_id   = "Z02735461PYN3BV0H30PI"
jenkins_account_id  = "398263320410"
project_name     = "digitalmarketplace"
services_desired_counts = {
  "api" : 4,
  "buyer-frontend" : 2
}
terraform_state_s3_bucket_name = "digital-marketplace-tfstate-dmp-aws-migrate"
terraform_state_dynamodb_table_name = "dmp-aws-migrate-state-locks"
vpc_cidr_block = "10.13.0.0/16"
vpc_public_subnets_cidr_blocks = {
  "a" : "10.13.1.0/24",
  "b" : "10.13.2.0/24"
}
vpc_private_subnets_cidr_blocks = {
  "a" : "10.13.65.0/24",
  "b" : "10.13.66.0/24"
}
