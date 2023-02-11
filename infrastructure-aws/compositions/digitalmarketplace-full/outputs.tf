output "apprunner_build_iam_role_arn" {
  description = "The ARN of the Role assumed by AppRunner Build"
  value       = aws_iam_role.apprunner_build.arn
}

output "apprunner_egress_vpc_connector_arn" {
  description = "ARN of the VPC connector through which outgoing AppRunner instance traffic is routed"
  value       = aws_apprunner_vpc_connector.services_egress.arn
}

output "apprunner_ingress_vpc_endpoint_id" {
  description = "ID of the VPC endpoint through which traaffic gains ingress to AppRunner services"
  value       = aws_vpc_endpoint.apprunner_services_ingress.id
}

output "ecr_repo_url_buyer_frontend" {
  description = "URL of the ECR repo for Buyer Frontend"
  value       = module.buyer_frontend_service.ecr_repo_url
}

output "fake_api_url" {
  description = "Open access endpoint to the fake API"
  value       = aws_lambda_function_url.fake_api.function_url
}

output "instance_role_buyer_frontend_arn" {
  description = "ARN of the service role created for AppRunner instances of the Buyer Frontend servuce"
  value       = module.buyer_frontend_service.instance_role_arn
}

output "vpc_id" {
  description = "ID of the VPC for the services"
  value       = module.dmp_vpc.vpc_id
}
