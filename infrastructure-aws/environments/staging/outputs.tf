output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = module.digitalmarketplace_full.apprunner_build_iam_role_arn
}

output "apprunner_egress_vpc_connector_arn" {
  description = "ARN of the VPC connector through which outgoing AppRunner instance traffic is routed"
  value       = module.digitalmarketplace_full.apprunner_egress_vpc_connector_arn
}

output "apprunner_ingress_vpc_endpoint_id" {
  description = "ID of the VPC endpoint through which traaffic gains ingress to AppRunner services"
  value       = module.digitalmarketplace_full.apprunner_ingress_vpc_endpoint_id
}

output "ecr_repo_url_buyer_frontend" {
  description = "URL of the ECR repo for Buyer Frontend"
  value       = module.digitalmarketplace_full.ecr_repo_url_buyer_frontend
}

output "fake_api_url" {
  description = "Open access endpoint to the fake API"
  value       = module.digitalmarketplace_full.fake_api_url
}

output "frontend_session_cache_nodes" {
  description = "List of node objects for the frontend session cache"
  value       = module.digitalmarketplace_full.frontend_session_cache_nodes
}

output "instance_role_buyer_frontend_arn" {
  description = "ARN of the service role created for AppRunner instances of the Buyer Frontend servuce"
  value       = module.digitalmarketplace_full.instance_role_buyer_frontend_arn
}

output "vpc_id" {
  description = "ID of the VPC for the services"
  value       = module.digitalmarketplace_full.vpc_id
}
