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

data "aws_caller_identity" "current" {}
