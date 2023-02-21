resource "aws_lb" "api" {
  name               = "${var.project_name}-${var.environment_name}-api"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.api_lb.id]
  subnets            = module.dmp_vpc.public_subnet_ids
}

resource "aws_lb_target_group" "api" {
  name            = "${var.environment_name}-api"
  ip_address_type = "ipv4"
  port            = "80"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = module.dmp_vpc.vpc_id

  health_check {
    matcher  = "200,401" # 401 is healthy
    path     = "/"
    port     = "80"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_security_group" "api_lb" {
  name        = "${var.project_name}-${var.environment_name}-api-lb"
  description = "API Network Load Balancer for ${var.project_name} (${var.environment_name})"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-api-lb"
  }
}

resource "aws_security_group" "api_lb_targets" {
  name        = "${var.environment_name}-api-services"
  description = "Identifies the holder as one of the API NLB targets"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.environment_name}-api-lb-targets"
  }
}

resource "aws_security_group_rule" "api_lb_http_in" {
  security_group_id        = aws_security_group.api_lb.id
  description              = "Allow HTTP from the frontend services"
  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend_lb_targets.id # At the LB level, this is how we identify the FE services
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "api_lb_http_targets_out" {
  security_group_id = aws_security_group.api_lb.id
  description       = "Allow outward service traffic from the API LB to the targets"

  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.api_lb_targets.id
  to_port                  = 80
  type                     = "egress"
}

resource "aws_security_group_rule" "api_targets_http_in" {
  description = "Allow inward service traffic from the API LB"

  security_group_id        = aws_security_group.api_lb_targets.id
  from_port                = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.api_lb.id
  to_port                  = 80
  type                     = "ingress"
}
