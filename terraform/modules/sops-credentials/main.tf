provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {
}

