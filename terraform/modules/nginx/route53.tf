resource "aws_route53_zone" "root" {
  name = "${var.domain}"
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name = "www.${var.domain}"
  type = "A"

  alias {
    name = "${aws_elb.nginx.dns_name}"
    zone_id = "${aws_elb.nginx.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name = "api.${var.domain}"
  type = "A"

  alias {
    name = "${aws_elb.nginx.dns_name}"
    zone_id = "${aws_elb.nginx.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "search_api" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name = "search-api.${var.domain}"
  type = "A"

  alias {
    name = "${aws_elb.nginx.dns_name}"
    zone_id = "${aws_elb.nginx.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "assets" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name = "assets.${var.domain}"
  type = "A"

  alias {
    name = "${aws_elb.nginx.dns_name}"
    zone_id = "${aws_elb.nginx.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "elasticsearch" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name = "elasticsearch.${var.domain}"
  type = "A"

  alias {
    name = "${aws_elb.nginx.dns_name}"
    zone_id = "${aws_elb.nginx.zone_id}"
    evaluate_target_health = true
  }
}
