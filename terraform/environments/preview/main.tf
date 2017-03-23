provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "digitalmarketplace-terraform-state-development"
    key = "environments/preview/terraform.tfstate"
    region = "eu-west-1"
    encrypt =  "true"
  }
}

module "preview_nginx" {
  source = "../../modules/nginx"

  name = "nginx-preview"
  environment = "preview"
  domain = "preview.marketplace.team"

  vpc_id = "vpc-a29149c7"
  subnet_ids = [
      "subnet-bf8c5ce6",
      "subnet-916bfcf4",
      "subnet-82dc63f5"
  ]

  ssl_cert_arn = "arn:aws:acm:eu-west-1:381494870249:certificate/5be12edd-af5b-4463-b3c5-acd3df600a1e"

  instance_count = "2"
  min_instance_count = "2"
  max_instance_count = "2"

  instance_type = "t2.micro"

  ssh_key_name = ""

  ami_owner_account_id = "${var.aws_main_account_id}"

  admin_user_ips = "${var.admin_user_ips}"
  dev_user_ips = "${var.dev_user_ips}"
  user_ips = "${var.user_ips}"

  log_retention_days = "180"

  g7_draft_documents_s3_url = ""
  documents_s3_url = ""
  agreements_s3_url = ""
  communications_s3_url = ""
  submissions_s3_url = ""

  api_url = ""
  search_api_url = ""
  buyer_frontend_url = ""
  admin_frontend_url = ""
  supplier_frontend_url = ""
  elasticsearch_url = ""

  elasticsearch_auth = ""
  app_auth = ""
}
