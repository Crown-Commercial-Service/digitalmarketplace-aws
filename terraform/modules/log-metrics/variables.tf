variable "environment" {}
variable "app_names" {
  type = "list"
  default = ["buyer-frontend", "supplier-frontend", "admin-frontend", "api", "search-api", "briefs-frontend"]
}
variable "request_time_buckets" {
  type = "list"
  default = [
    {
      min = "0",
      max = "0.025"
    },
    {
      min = "0.025",
      max = "0.05"
    },
    {
      min = "0.05",
      max = "0.1"
    },
    {
      min = "0.1",
      max = "0.25"
    },
    {
      min = "0.25",
      max = "0.5"
    },
    {
      min = "0.5",
      max = "1"
    },
    {
      min = "1",
      max = "2.5"
    },
    {
      min = "2.5",
      max = "5"
    },
    {
      min = "5",
      max = "10"
    },
    {
      min = "10",
      max = "500"
    }
  ]
}
