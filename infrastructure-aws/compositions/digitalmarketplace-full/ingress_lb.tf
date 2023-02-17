resource "aws_lb" "ingress" {
  name               = "${var.project_name}-${var.environment_name}"
  internal           = false
  load_balancer_type = "network"

  subnets = module.dmp_vpc.public_subnet_ids
}

# TODO rename all the groups etc on both layers with MOVEs when this is working

resource "aws_lb_target_group" "ingress_http" {
  name        = "${var.environment_name}-ingress-http"
  port        = "443"
  protocol    = "TCP"
  target_type = "alb"
  vpc_id      = module.dmp_vpc.vpc_id

  health_check {
    matcher  = "200"
    path     = "/"
    port     = "80"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ingress.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_http.arn
  }
  port     = "443"
  protocol = "TCP"
}

resource "aws_lb_target_group_attachment" "buyer_frontend" { # Temporarily. Will eventually be the DMP Router
  port             = 443
  target_group_arn = aws_lb_target_group.ingress_http.arn
  target_id        = module.buyer_frontend_service.alb_arn
}

resource "aws_route53_record" "ingress" {
  name            = var.domain_name
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone_id
  alias {
    name                   = aws_lb.ingress.dns_name
    zone_id                = aws_lb.ingress.zone_id
    evaluate_target_health = true
  }
}
