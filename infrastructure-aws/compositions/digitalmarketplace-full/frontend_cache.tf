resource "aws_elasticache_cluster" "frontend_cache" {
  cluster_id           = "${var.project_name}-${var.environment_name}-session-cache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  security_group_ids   = [aws_security_group.frontend_cache.id]
  subnet_group_name    = aws_elasticache_subnet_group.frontend_cache.name
}

resource "aws_elasticache_subnet_group" "frontend_cache" {
  name       = "${var.project_name}-${var.environment_name}-session-cache"
  subnet_ids = module.dmp_vpc.private_subnet_ids
}


resource "aws_security_group" "frontend_cache" {
  name        = "${var.environment_name}-frontend-cache"
  description = "The ${var.environment_name} Redis cache"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.environment_name}-frontend-cache"
  }
}

resource "aws_security_group_rule" "redis_from_services" {
  description = "Allow Redis traffic from the FE services"

  security_group_id        = aws_security_group.frontend_cache.id
  from_port                = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend_lb_targets.id
  to_port                  = 6379
  type                     = "ingress"
}
