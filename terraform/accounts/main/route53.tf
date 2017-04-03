resource "aws_route53_zone" "marketplace_team" {
  name = "marketplace.team"
}

resource "aws_route53_record" "preview_ns" {
  zone_id = "${aws_route53_zone.marketplace_team.zone_id}"
  name = "preview.marketplace.team"
  type = "NS"
  ttl = "3600"
  records = [
    "ns-389.awsdns-48.com",
    "ns-2018.awsdns-60.co.uk",
    "ns-1176.awsdns-19.org",
    "ns-530.awsdns-02.net",
  ]
}

resource "aws_route53_record" "staging_ns" {
  zone_id = "${aws_route53_zone.marketplace_team.zone_id}"
  name = "staging.marketplace.team"
  type = "NS"
  ttl = "3600"
  records = [
    "ns-175.awsdns-21.com",
    "ns-781.awsdns-33.net",
    "ns-1457.awsdns-54.org",
    "ns-1828.awsdns-36.co.uk",
  ]
}
