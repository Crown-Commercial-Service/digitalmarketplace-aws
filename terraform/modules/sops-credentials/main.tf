provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.70"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {
}

