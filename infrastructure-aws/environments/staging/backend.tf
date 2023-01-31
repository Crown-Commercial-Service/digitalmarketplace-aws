terraform {
  backend "s3" {
    /* Note that for this POC we are locating the statefile bucket and the state
       lock table inside the AWS account which is under Terraform control. This is
       suboptimal in terms of best practice however this is a POC / temporary account.

       TODO Implement a central administration account approach to isolated state
       management as per https://developer.hashicorp.com/terraform/language/settings/backends/s3#administrative-account-setup
    */
    bucket         = "digital-marketplace-tfstate-dmp-aws-migrate"
    dynamodb_table = "dmp-aws-migrate-state-locks"
    key            = "dmp-aws-migrate/tfstate"
    region         = "eu-west-1"
  }
}
