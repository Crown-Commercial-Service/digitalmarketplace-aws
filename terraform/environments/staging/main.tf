provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "digitalmarketplace-terraform-state-production"
    key = "environments/staging/terraform.tfstate"
    region = "eu-west-1"
    encrypt =  "true"
  }
}

module "staging_nginx" {
  source = "../../modules/nginx"

  name = "staging-nginx"
  environment = "staging"
  domain = "staging.marketplace.team"

  vpc_id = "vpc-70319115"
  subnet_ids = [
      "subnet-9a9713ed",
      "subnet-63b1683a",
      "subnet-ad0894c8"
  ]

  instance_count = "2"
  min_instance_count = "2"
  max_instance_count = "2"

  instance_type = "t2.micro"

  log_retention_days = "180"

  ami_owner_account_id = "${var.aws_main_account_id}"

  ssh_key_name = "${var.ssh_key_name}"

  admin_user_ips = "${var.admin_user_ips}"
  dev_user_ips = "${var.dev_user_ips}"
  user_ips = "${var.user_ips}"

  g7_draft_documents_s3_url = "${var.g7_draft_documents_s3_url}"
  documents_s3_url = "${var.documents_s3_url}"
  agreements_s3_url = "${var.agreements_s3_url}"
  communications_s3_url = "${var.communications_s3_url}"
  submissions_s3_url = "${var.submissions_s3_url}"

  api_url = "${var.api_url}"
  search_api_url = "${var.search_api_url}"
  frontend_url = "${var.frontend_url}"
  elasticsearch_url = "${module.staging_elasticsearch.elb_url}"

  elasticsearch_auth = "${var.elasticsearch_auth}"
  app_auth = "${var.app_auth}"

  mode = "${var.mode}"
}

module "staging_elasticsearch" {
  source = "../../modules/elasticsearch"

  name = "staging-elasticsearch"
  environment = "staging"

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

  nginx_security_group_id = "${module.staging_nginx.instance_security_group_id}"
}

module "application_logs" {
  source = "../../modules/application-logs"

  environment = "staging"
  retention_in_days = "180"
}

module "log_streaming" {
  source = "../../modules/log-streaming"

  name = "staging-log-stream-lambda"
  elasticsearch_url = "${var.logs_elasticsearch_url}"
  elasticsearch_api_key = "${var.logs_elasticsearch_api_key}"

  nginx_log_groups = ["${concat(module.staging_nginx.json_log_groups, module.application_logs.nginx_log_groups)}"]
  application_log_groups = ["${module.application_logs.application_log_groups}"]
}

module "log_metrics" {
  source = "../../modules/log-metrics"
  environment = "staging"
  app_names = ["${module.application_logs.app_names}"]
}
