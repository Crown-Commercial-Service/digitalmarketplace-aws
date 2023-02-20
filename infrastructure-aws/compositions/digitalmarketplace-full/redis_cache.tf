resource "aws_elasticache_cluster" "frontend_sessions" {
  cluster_id           = "${var.project_name}-${var.environment_name}-session-cache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  security_group_ids   = [aws_security_group.frontend_session_cache.id]
  subnet_group_name    = aws_elasticache_subnet_group.frontend_sessions.name
}

resource "aws_elasticache_subnet_group" "frontend_sessions" {
  name       = "${var.project_name}-${var.environment_name}-session-cache"
  subnet_ids = module.dmp_vpc.private_subnet_ids
}


resource "aws_security_group" "frontend_session_cache" {
  name        = "${var.environment_name}-session-cache"
  description = "The ${var.environment_name} Redis cache"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.environment_name}-session-cache"
  }
}

resource "aws_security_group_rule" "redis_from_services" {
  description = "Allow Redis traffic from the services"

  security_group_id        = aws_security_group.frontend_session_cache.id
  from_port                = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_target_group.id
  to_port                  = 6379
  type                     = "ingress"
}
