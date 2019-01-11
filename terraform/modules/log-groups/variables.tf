variable "environment" {}
variable "retention_in_days" {}

variable "app_names" {
  type = "list"

  default = [
    "buyer-frontend",
    "supplier-frontend",
    "admin-frontend",
    "api",
    "search-api",
    "briefs-frontend",
    "brief-responses-frontend",
    "user-frontend",
    "antivirus-api",
  ]
}
