provider "aws" {
  region = "eu-west-1"
}

resource "aws_route53_zone" "root" {
  name = var.domain
}

resource "aws_route53_record" "www_acm_validation" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "${var.www_acm_name}${var.domain}"
  type    = "CNAME"
  ttl     = "86400"

  records = [
    var.www_acm_value,
  ]
}

resource "aws_route53_record" "api_acm_validation" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "${var.api_acm_name}${var.domain}"
  type    = "CNAME"
  ttl     = "86400"

  records = [
    var.api_acm_value,
  ]
}

resource "aws_route53_record" "search_api_acm_validation" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "${var.search_api_acm_name}${var.domain}"
  type    = "CNAME"
  ttl     = "86400"

  records = [
    var.search_api_acm_value,
  ]
}

resource "aws_route53_record" "antivirus_api_acm_validation" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "${var.antivirus_api_acm_name}${var.domain}"
  type    = "CNAME"
  ttl     = "86400"

  records = [
    var.antivirus_api_acm_value,
  ]
}

resource "aws_route53_record" "assets_acm_validation" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "${var.www_acm_name}${var.domain}"
  type    = "CNAME"
  ttl     = "86400"

  records = [
    var.assets_acm_value,
  ]
}

resource "aws_route53_record" "www" {
  count   = length(var.cname_domain) == 0 ? 0 : 1
  zone_id = aws_route53_zone.root.zone_id
  name    = "www.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    var.cname_domain,
  ]
}

resource "aws_route53_record" "api" {
  count   = length(var.cname_domain) == 0 ? 0 : 1
  zone_id = aws_route53_zone.root.zone_id
  name    = "api.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    var.cname_domain,
  ]
}

resource "aws_route53_record" "search_api" {
  count   = length(var.cname_domain) == 0 ? 0 : 1
  zone_id = aws_route53_zone.root.zone_id
  name    = "search-api.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    var.cname_domain,
  ]
}

resource "aws_route53_record" "antivirus_api" {
  count   = length(var.cname_domain) == 0 ? 0 : 1
  zone_id = aws_route53_zone.root.zone_id
  name    = "antivirus-api.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    var.cname_domain,
  ]
}

resource "aws_route53_record" "assets" {
  count   = length(var.cname_domain) == 0 ? 0 : 1
  zone_id = aws_route53_zone.root.zone_id
  name    = "assets.${var.domain}"
  type    = "CNAME"
  ttl     = "600"

  records = [
    var.cname_domain,
  ]
}

