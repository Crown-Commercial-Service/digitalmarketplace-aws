variable "name" {
}

variable "elasticsearch_url" {
}

variable "elasticsearch_api_key" {
}

variable "nginx_log_groups" {
  type = list(string)
}

variable "application_log_groups" {
  type = list(string)
}

