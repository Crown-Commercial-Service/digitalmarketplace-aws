resource "aws_route53_zone" "root" {
  name = "${var.domain}"
}

resource "aws_route53_record" "www_acme_challenge" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "_acme-challenge.www.${var.domain}"
  type    = "TXT"
  ttl     = "120"

  records = [
    "${var.www_acme_challenge}",
  ]
}

resource "aws_route53_record" "api_acme_challenge" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "_acme-challenge.api.${var.domain}"
  type    = "TXT"
  ttl     = "120"

  records = [
    "${var.api_acme_challenge}",
  ]
}

resource "aws_route53_record" "search_api_acme_challenge" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "_acme-challenge.search-api.${var.domain}"
  type    = "TXT"
  ttl     = "120"

  records = [
    "${var.search_api_acme_challenge}",
  ]
}

resource "aws_route53_record" "assets_acme_challenge" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "_acme-challenge.assets.${var.domain}"
  type    = "TXT"
  ttl     = "120"

  records = [
    "${var.assets_acme_challenge}",
  ]
}

resource "aws_route53_record" "www" {
  count   = "${length(var.cname_domain) == 0 ? 0 : 1}"
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "www.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    "${var.cname_domain}",
  ]
}

resource "aws_route53_record" "api" {
  count   = "${length(var.cname_domain) == 0 ? 0 : 1}"
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "api.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    "${var.cname_domain}",
  ]
}

resource "aws_route53_record" "search_api" {
  count   = "${length(var.cname_domain) == 0 ? 0 : 1}"
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "search-api.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    "${var.cname_domain}",
  ]
}

resource "aws_route53_record" "antivirus_api" {
  count   = "${length(var.cname_domain) == 0 ? 0 : 1}"
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "antivirus-api.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    "${var.cname_domain}",
  ]
}

resource "aws_route53_record" "assets" {
  count   = "${length(var.cname_domain) == 0 ? 0 : 1}"
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "assets.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    "${var.cname_domain}",
  ]
}
