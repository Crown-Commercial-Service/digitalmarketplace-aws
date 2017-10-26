variable "name" {}
variable "domain" {}
variable "cname_domain" {
  default = ""
}

variable "www_acme_challenge" {}
variable "api_acme_challenge" {}
variable "search_api_acme_challenge" {}
variable "assets_acme_challenge" {}
variable "log_retention_days" {}
