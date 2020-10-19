provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.70"
}

data "aws_caller_identity" "current" {
}

