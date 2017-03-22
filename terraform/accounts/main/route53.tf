resource "aws_route53_zone" "marketplace_team" {
  name = "marketplace.team"
}

resource "aws_route53_record" "preview_ns" {
  zone_id = "${aws_route53_zone.marketplace_team.zone_id}"
  name = "preview.marketplace.team"
  type = "NS"
  ttl = "3600"
  records = ["${var.preview_name_servers}"]
}

resource "aws_route53_record" "staging_ns" {
  zone_id = "${aws_route53_zone.marketplace_team.zone_id}"
  name = "staging.marketplace.team"
  type = "NS"
  ttl = "3600"
  records = ["${var.staging_name_servers}"]
}
