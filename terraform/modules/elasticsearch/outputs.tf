output "elb_url" {
  value = "http://${aws_elb.elasticsearch_elb.dns_name}"
}
