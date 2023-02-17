resource "aws_lb" "alb" {
  name               = "${var.environment_name}-${var.service_name}"
  internal           = true
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = var.service_security_group_ids
  subnets            = var.service_subnet_ids
}

resource "aws_lb_target_group" "http" {
  name            = "${var.environment_name}-${var.service_name}-http"
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

resource "aws_lb_listener" "http" { # TODO RENAME MOVE
  load_balancer_arn = aws_lb.alb.arn
  certificate_arn   = var.temp_cert_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "health" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "I am OK"
      status_code  = 200
    }
  }
}
