output "route53_zone_id" {
  value = "${aws_route53_zone.root.zone_id}"
}

output "json_log_groups" {
  value = ["${aws_cloudwatch_log_group.json_logs.name}"]
}
