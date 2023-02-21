locals {
  redis_uri                   = "${aws_elasticache_cluster.frontend_cache.cache_nodes[0]["address"]}:${aws_elasticache_cluster.frontend_cache.cache_nodes[0]["port"]}"
  service_name_api            = "api"
  service_name_buyer_frontend = "buyer-frontend"
}
