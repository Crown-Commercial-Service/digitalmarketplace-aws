data "aws_caller_identity" "current" {}

module "users" {
  source = "users"
}
