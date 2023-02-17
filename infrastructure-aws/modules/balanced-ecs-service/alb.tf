resource "aws_lb" "alb" {
  name               = "${var.environment_name}-${var.service_name}"
  internal           = true
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = var.service_security_group_ids
  subnets            = var.service_subnet_ids
}

resource "aws_lb_target_group" "target" {
  name            = "${var.environment_name}-${var.service_name}"
  ip_address_type = "ipv4"
  port            = "80"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = var.vpc_id

  health_check {
    matcher  = "200,401" # 401 is healthy
    path     = "/"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}
