resource "aws_lb" "ingress" {
  name               = "${var.project_name}-${var.environment_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ingress_alb.id]
  subnets            = module.dmp_vpc.public_subnet_ids
}

resource "aws_lb_listener" "ingress_https" {
  load_balancer_arn = aws_lb.ingress.arn
  certificate_arn   = aws_acm_certificate.ingress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.buyer_frontend.arn # Later iterations will contain an action for each original "route" target
  }
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

resource "aws_security_group" "ingress_alb" {
  name        = "${var.project_name}-${var.environment_name}-ingress-alb"
  description = "Ingress Application Load Balancer for ${var.project_name}(${var.environment_name})"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-ingress-alb"
  }
}

resource "aws_security_group_rule" "ingress_alb_https_public" {
  security_group_id = aws_security_group.ingress_alb.id
  description       = "Allow HTTPS from anywhere"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port = 443
  protocol  = "tcp"
  to_port   = 443
  type      = "ingress"
}

resource "aws_security_group_rule" "alb_egress_service" {
  security_group_id = aws_security_group.ingress_alb.id
  description       = "Allow outbound service traffic to all holders of ${var.environment_name}-alb-target-group"

  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_target_group.id
  to_port                  = 80
  type                     = "egress"
}

resource "aws_security_group" "alb_target_group" {
  name        = "${var.environment_name}-alb-target-group"
  description = "Allows the ${var.project_name}-${var.environment_name} ALB to access the group holder"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.environment_name}-alb-target-group"
  }
}

resource "aws_security_group_rule" "allow_alb_service_traffic" {
  description = "Allow service traffic from the ALB to the holder"

  security_group_id        = aws_security_group.alb_target_group.id
  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ingress_alb.id
  to_port                  = 80
  type                     = "ingress"

}
