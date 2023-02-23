aws_region       = "eu-west-1"
domain_name      = "dmp.techopsdev.com"
environment_name = "staging"
hosted_zone_id   = "Z09653222IAUZ39EAVI3Q"
project_name     = "digitalmarketplace"
services_desired_counts = {
  "api" : 4,
  "buyer-frontend" : 2
}
vpc_cidr_block = "10.13.0.0/16"
vpc_public_subnets_cidr_blocks = {
  "a" : "10.13.1.0/24",
  "b" : "10.13.2.0/24"
}
vpc_private_subnets_cidr_blocks = {
  "a" : "10.13.65.0/24",
  "b" : "10.13.66.0/24"
}
