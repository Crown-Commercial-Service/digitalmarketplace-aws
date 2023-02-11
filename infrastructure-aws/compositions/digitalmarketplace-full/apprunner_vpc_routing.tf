resource "aws_vpc_endpoint" "apprunner_services_ingress" {
  vpc_endpoint_type = "Interface"

  dns_options {
    dns_record_ip_type = "ipv4"
  }
  ip_address_type     = "ipv4"
  private_dns_enabled = false
  security_group_ids  = [module.dmp_vpc.default_security_group_id]
  service_name        = "com.amazonaws.${var.aws_region}.apprunner.requests"
  subnet_ids          = module.dmp_vpc.private_subnet_ids
  vpc_id              = module.dmp_vpc.vpc_id

  tags = {
    "Name" = "${var.project_name}-${var.environment_name}-apprunner-services-ingress"
  }
}

resource "aws_apprunner_vpc_connector" "services_egress" {
  vpc_connector_name = "${var.project_name}-${var.environment_name}"
  security_groups    = [module.dmp_vpc.default_security_group_id]
  subnets            = module.dmp_vpc.private_subnet_ids
}
