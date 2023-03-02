locals {
  db_connect_uri              = "postgresql://${local.db_username}:${random_password.dmp_db.result}@${module.dmp_db.rds_db_endpoint}/${local.db_name}"
  db_name                     = "${var.project_name}_${var.environment_name}" # PostgreSQL uses underscores not hyphens
  db_username                 = "postgres"
  redis_uri                   = "${aws_elasticache_cluster.frontend_cache.cache_nodes[0]["address"]}:${aws_elasticache_cluster.frontend_cache.cache_nodes[0]["port"]}"
  service_name_api            = "api"
  service_name_buyer_frontend = "buyer-frontend"
  service_name_user_frontend  = "user-frontend"
}
