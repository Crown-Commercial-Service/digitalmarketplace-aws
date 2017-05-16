provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "digitalmarketplace-terraform-state-production"
    key = "environments/production/terraform.tfstate"
    region = "eu-west-1"
    encrypt =  "true"
  }
}

module "production_nginx" {
  source = "../../modules/nginx"

  name = "production-nginx"
  environment = "production"
  domain = "digitalmarketplace.service.gov.uk"

  vpc_id = "vpc-70319115"
  subnet_ids = [
      "subnet-9a9713ed",
      "subnet-63b1683a",
      "subnet-ad0894c8"
  ]

  instance_count = "2"
  min_instance_count = "2"
  max_instance_count = "2"

  instance_type = "t2.medium"

  log_retention_days = "3653"

  ami_owner_account_id = "${var.aws_main_account_id}"

  ssh_key_name = "${var.ssh_key_name}"

  admin_user_ips = "${var.admin_user_ips}"
  dev_user_ips = "${var.dev_user_ips}"
  user_ips = ["0.0.0.0/0"]

  g7_draft_documents_s3_url = "${var.g7_draft_documents_s3_url}"
  documents_s3_url = "${var.documents_s3_url}"
  agreements_s3_url = "${var.agreements_s3_url}"
  communications_s3_url = "${var.communications_s3_url}"
  submissions_s3_url = "${var.submissions_s3_url}"

  api_url = "${var.api_url}"
  search_api_url = "${var.search_api_url}"
  buyer_frontend_url = "${var.buyer_frontend_url}"
  admin_frontend_url = "${var.admin_frontend_url}"
  supplier_frontend_url = "${var.supplier_frontend_url}"
  elasticsearch_url = "${module.production_elasticsearch.elb_url}"

  elasticsearch_auth = "${var.elasticsearch_auth}"
  app_auth = "${var.app_auth}"

  mode = "${var.mode}"
}

module "production_elasticsearch" {
  source = "../../modules/elasticsearch"

  name = "production-elasticsearch"
  environment = "production"

  vpc_id = "vpc-70319115"
  subnet_ids = [
      "subnet-9a9713ed",
      "subnet-63b1683a",
      "subnet-ad0894c8"
  ]

  instance_count = "3"
  min_instance_count = "3"
  max_instance_count = "3"

  instance_type = "t2.micro"

  log_retention_days = "180"

  ami_owner_account_id = "${var.aws_main_account_id}"

  ssh_key_name = "${var.ssh_key_name}"

  nginx_security_group_id = "${module.production_nginx.instance_security_group_id}"
}

module "application_logs" {
  source = "../../modules/application-logs"

  environment = "production"
  retention_in_days = "3653"
}

module "log_streaming" {
  source = "../../modules/log-streaming"

  name = "production-log-stream-lambda"
  elasticsearch_url = "${var.logs_elasticsearch_url}"

  log_groups = ["${concat(module.production_nginx.json_log_groups, module.application_logs.log_groups)}"]
}
