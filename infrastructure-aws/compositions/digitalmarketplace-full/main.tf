module "buyer_frontend_service" {
  source = "../../modules/balanced-ecs-service"

  aws_region              = var.aws_region
  aws_target_account      = var.aws_target_account
  desired_count           = var.services_desired_counts[local.service_name_buyer_frontend]
  ecs_cluster_arn         = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn  = aws_iam_role.execution_role.arn
  ecs_execution_role_name = aws_iam_role.execution_role.name
  fake_api_url            = aws_lambda_function_url.fake_api.function_url
  environment_name        = var.environment_name
  project_name            = var.project_name
  service_name            = local.service_name_buyer_frontend
  service_security_group_ids = [
    module.dmp_vpc.default_security_group_id,
    aws_security_group.ingress_alb_http_s.id
  ]
  service_subnet_ids  = module.dmp_vpc.private_subnet_ids
  session_cache_nodes = aws_elasticache_cluster.frontend_sessions.cache_nodes

  temp_cert_arn = aws_acm_certificate.ingress.arn

  vpc_id = module.dmp_vpc.vpc_id
}

resource "aws_security_group" "allow_https_from_vpc" { # TODO REMOVE
  name        = "allow_https_from_vpc"
  description = "Allow HTTPS from within VPC"
  vpc_id      = module.dmp_vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_http_https_from_vpc" { # TODO REMOVE
  name        = "vpc_http_https"
  description = "Allow HTTP and HTTPS from within VPC"
  vpc_id      = module.dmp_vpc.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ingress_alb_http_s" { # NOTE name foreshadows restructure of ALBs when >1 service
  name        = "ingress_alb_http_s"
  description = "HTTP and HTTPS for the ingress ALB"
  vpc_id      = module.dmp_vpc.vpc_id

  ingress {
    description = "HTTP from VPC (for healthchecks)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "HTTPS from everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
