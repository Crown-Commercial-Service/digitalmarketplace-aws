variable "dev_user_ips" {
  type = "list"
}

variable "jenkins_public_key_name" {}

variable "name" {}
variable "jenkins_wildcard_elb_cert_arn" {}
variable "jenkins_instance_profile" {}
variable "ami_id" {}
variable "instance_type" {}
variable "dns_zone_id" {}
variable "dns_name" {}
variable "log_bucket_name" {}
