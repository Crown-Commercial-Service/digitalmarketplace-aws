aws_region                          = "eu-west-1"
domain_name                         = "dmp.techopsdev.com"
environment_is_ephemeral            = true
environment_name                    = "staging"
hosted_zone_id                      = "Z09653222IAUZ39EAVI3Q"
jenkins_account_id                  = "398263320410"
project_name                        = "digitalmarketplace"
services_container_memories         = {
  "api" : 2048,
  "admin-frontend" : 1024,
  "buyer-frontend" : 1024,
  "user-frontend" : 1024
}
services_desired_counts             = {
  "api" : 4,
  "admin-frontend" : 1
  "buyer-frontend" : 2
  "user-frontend" : 2
}
terraform_state_s3_bucket_name      = "digital-marketplace-tfstate-dmp-aws-migrate"
terraform_state_dynamodb_table_name = "dmp-aws-migrate-state-locks"
vpc_cidr_block                      = "10.13.0.0/16"
vpc_public_subnets_cidr_blocks      = {
  "a" : "10.13.1.0/24",
  "b" : "10.13.2.0/24"
}
vpc_private_subnets_cidr_blocks     = {
  "a" : "10.13.65.0/24",
  "b" : "10.13.66.0/24"
}
