resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-development"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38.0"
    }
  }
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-development"
    key     = "accounts/development/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

resource "aws_s3_bucket_policy" "development_tfstate_bucket_policy" {
  bucket = "digitalmarketplace-terraform-state-development"
  policy = jsonencode({
    Version = "2012-10-17"
    Id = "DevTFStateOnlyEncryptedConnectionPolicy"
    Statement = [
      {
        Effect: "Deny",
        Principal: "*",
        Action: "*",
        Resource: "arn:aws:s3:::digitalmarketplace-terraform-state-development/*",
        Condition: {
            Bool: {
                "aws:SecureTransport": "false"
            }
        }
      }
    ]
  })
}

module "iam_common" {
  source                            = "../../modules/iam-common"
  aws_account_and_jenkins_login_ips = var.aws_account_and_jenkins_login_ips
  aws_main_account_id               = var.aws_main_account_id
  aws_dev_account_id                = var.aws_dev_account_id
}

module "switch_roles" {
  source                          = "../../modules/switch-roles"
  ip_restricted_access_policy_arn = module.iam_common.aws_iam_policy_ip_restricted_access_arn
  iam_manage_account_policy_arn   = module.iam_common.aws_iam_policy_iam_manage_account_arn
  aws_main_account_id             = var.aws_main_account_id
}

module "paas" {
  source = "../../modules/paas"
}

# TODO remove old csw_inspector_role in favour of new gds_security_audit_role when switch to new role  is completed by secops
module "csw_inspector_role" {
  source               = "git::https://github.com/alphagov/csw-client-role.git?ref=f348d3f9e12a93ffab6937053360f5b9d9015f82"
  csw_agent_account_id = var.csw_agent_account_id
}

module "gds_security_audit_role" {
  source           = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=720885a9769c40942ff30b32179e1fad18f2ca10"
  chain_account_id = var.gds_security_audit_chain_account_id
}

