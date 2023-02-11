resource "aws_elasticache_cluster" "frontend_sessions" {
  cluster_id           = "${var.project_name}-${var.environment_name}-session-cache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  security_group_ids   = [module.dmp_vpc.default_security_group_id]
  subnet_group_name    = aws_elasticache_subnet_group.frontend_sessions.name
}

resource "aws_elasticache_subnet_group" "frontend_sessions" {
  name       = "${var.project_name}-${var.environment_name}-session-cache"
  subnet_ids = module.dmp_vpc.private_subnet_ids
}
