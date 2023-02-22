locals {
  container_port = 80 # TODO variable
}

resource "aws_security_group" "service" {
  name        = "${var.environment_name}-${var.service_name}"
  description = "ECS Service ${var.service_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment_name}-${var.service_name}"
  }
}

resource "aws_security_group_rule" "service_egress_all" {
  security_group_id = aws_security_group.service.id
  description       = "Allow all outbound traffic"

  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
  type        = "egress"
}

resource "aws_ecs_service" "service" {
  name                 = "${var.project_name}-${var.environment_name}-${var.service_name}"
  cluster              = var.ecs_cluster_arn
  desired_count        = var.desired_count
  force_new_deployment = false
  launch_type          = "FARGATE"
  load_balancer {
    container_name   = var.service_name
    container_port   = tostring(local.container_port)
    target_group_arn = var.lb_target_group_arn
  }
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.service.id,
      var.target_group_security_group_id
    ]
    subnets = var.service_subnet_ids
  }
  task_definition = module.service_task_definition.task_definition_arn
}

module "service_task_definition" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_region                      = var.aws_region
  aws_target_account              = var.aws_target_account
  container_environment_variables = var.container_environment_variables
  container_log_group_name        = module.container_log_group.log_group_name
  container_name                  = var.service_name
  container_port                  = local.container_port
  ecr_repo_url                    = module.ecr_repo.repo_url
  ecs_execution_role_arn          = var.ecs_execution_role_arn
  family_name                     = "${var.project_name}-${var.environment_name}-${var.service_name}"
}
