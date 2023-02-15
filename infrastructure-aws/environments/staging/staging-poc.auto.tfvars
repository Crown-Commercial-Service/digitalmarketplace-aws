aws_region       = "eu-west-1"
environment_name = "staging"
project_name     = "digitalmarketplace"
services_desired_counts = {
  "buyer-frontend" : 1
}
vpc_cidr_block                = "10.13.0.0/16"
vpc_public_subnet_cidr_block  = "10.13.1.0/24"
vpc_private_subnet_cidr_block = "10.13.129.0/24"
