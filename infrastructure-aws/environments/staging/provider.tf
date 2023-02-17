provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment  = "dmp-migrate-poc-staging"
      Organisation = "CCS"
      Project      = "digitalmarketplace"
    }
  }
}

# provider "aws" {
#   alias  = "us-east-1"
#   region = "us-east-1"
# }

data "aws_caller_identity" "current" {}
