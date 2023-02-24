resource "aws_lb" "frontend" {
  name               = "${var.project_name}-${var.environment_name}-fe"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb.id]
  subnets            = module.dmp_vpc.public_subnet_ids
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = aws_lb.frontend.arn
  certificate_arn   = aws_acm_certificate.ingress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.buyer_frontend.arn # The default (serves from unconsumed `/` root)
  }
}

resource "aws_lb_listener_rule" "user_frontend" {
  listener_arn = aws_lb_listener.frontend_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_frontend.arn
  }
  condition {
    path_pattern {
      values = ["/user/*"]
    }
  }
}

resource "aws_route53_record" "frontend" {
  name            = var.domain_name
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone_id
  alias {
    name                   = aws_lb.frontend.dns_name
    zone_id                = aws_lb.frontend.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "frontend_alb" {
  name        = "${var.project_name}-${var.environment_name}-frontend-alb"
  description = "Frontend Application Load Balancer for ${var.project_name} (${var.environment_name})"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-frontend-alb"
  }
}

resource "aws_security_group" "frontend_lb_targets" {
  name        = "${var.environment_name}-frontend-services"
  description = "Identifies the holder as one of the frontend ALB targets"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.environment_name}-frontend-lb-targets"
  }
}

resource "aws_security_group_rule" "frontend_alb_https_public_in" {
  security_group_id = aws_security_group.frontend_alb.id
  description       = "Allow HTTPS from anywhere to the ALB"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port = 443
  protocol  = "tcp"
  to_port   = 443
  type      = "ingress"
}

resource "aws_security_group_rule" "frontend_alb_http_targets_out" {
  security_group_id = aws_security_group.frontend_alb.id
  description       = "Allow outward service traffic from the ALB to the targets"

  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend_lb_targets.id
  to_port                  = 80
  type                     = "egress"
}

resource "aws_security_group_rule" "frontend_targets_http_in" {
  description = "Allow inward service traffic from the ALB"

  security_group_id        = aws_security_group.frontend_lb_targets.id
  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend_alb.id
  to_port                  = 80
  type                     = "ingress"

}
