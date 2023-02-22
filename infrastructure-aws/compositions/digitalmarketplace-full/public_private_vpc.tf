module "dmp_vpc" {
  source = "../../resource-groups/public-private-vpc"

  aws_region                      = var.aws_region
  environment_name                = var.environment_name
  project_name                    = var.project_name
  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_private_subnets_cidr_blocks = var.vpc_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks  = var.vpc_public_subnets_cidr_blocks
}

resource "aws_security_group" "egress_all" {
  name        = "${var.environment_name}-egress-all"
  description = "Allows for traffic to anywhere"
  vpc_id      = module.dmp_vpc.vpc_id

  tags = {
    Name = "${var.environment_name}-egress-all"
  }
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.egress_all.id
  description       = "Allow all outbound traffic"

  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
  type        = "egress"
}
