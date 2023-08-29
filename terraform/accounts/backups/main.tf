provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "digitalmarketplace-backups"
}

# TODO remove old csw_inspector_role in favour of new gds_security_audit_role when switch to new role  is completed by secops
module "csw_inspector_role" {
  source               = "git::https://github.com/alphagov/csw-client-role.git?ref=f348d3f9e12a93ffab6937053360f5b9d9015f82"
  csw_agent_account_id = var.csw_agent_account_id
}

module "cyber_security_audit_role" {
  source           = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=720885a9769c40942ff30b32179e1fad18f2ca10"
  chain_account_id = var.gds_security_audit_chain_account_id
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.76.1"
    }
  }
  backend "s3" {
    bucket  = "digitalmarketplace-terraform-state-backups"
    key     = "accounts/backups/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

resource "aws_s3_bucket_policy" "backups_tfstate_bucket_policy" {
  bucket = "digitalmarketplace-terraform-state-backups"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BackupsTFStateOnlyEncryptedConnectionPolicy"
    Statement = [
      {
        Effect : "Deny",
        Principal : "*",
        Action : "*",
        Resource : "arn:aws:s3:::digitalmarketplace-terraform-state-backups/*",
        Condition : {
          Bool : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}