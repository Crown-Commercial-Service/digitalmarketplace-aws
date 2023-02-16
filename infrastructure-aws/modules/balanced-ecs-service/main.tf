locals {
  container_name = var.service_name
  container_port = 80 # TODO variable
  redis_uri      = "${var.session_cache_nodes[0]["address"]}:${var.session_cache_nodes[0]["port"]}"
}

resource "aws_ecs_service" "service" {
  name                 = "${var.project_name}-${var.environment_name}-${var.service_name}"
  cluster              = var.ecs_cluster_arn
  desired_count        = var.desired_count
  force_new_deployment = false # Don't deploy on Terraform apply - wait for deployment script
  launch_type          = "FARGATE"
  load_balancer {
    container_name   = local.container_name
    container_port   = tostring(local.container_port)
    target_group_arn = aws_lb_target_group.target.arn
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = var.service_security_group_ids
    subnets          = var.service_subnet_ids
  }
  task_definition = aws_ecs_task_definition.service.arn
}

resource "aws_ecs_task_definition" "service" {
  family = "${var.project_name}-${var.environment_name}-${var.service_name}"
  container_definitions = jsonencode([
    {
      name = local.container_name
      environment = [
        { "name" : "DM_APP_NAME", "value" : var.service_name },
        { "name" : "DM_ENVIRONMENT", "value" : var.environment_name },
        { "name" : "DM_LOG_PATH", "value" : "/dev/null" },
        { "name" : "DM_REDIS_SERVICE_NAME", "value" : "redis" },
        { "name" : "VCAP_SERVICES", "value" : "{\"redis\": [{\"name\": \"redis\", \"credentials\": {\"uri\": \"redis://${local.redis_uri}\"}}]}" },
        { "name" : "PORT", "value" : tostring(local.container_port) },
        { "name" : "PROXY_AUTH_CREDENTIALS", "value" : "poc:$apr1$ucZGAcrR$AZlxfQzm2vrYJT/HYwBWF/" },
        { "name" : "DM_DATA_API_URL", "value" : var.fake_api_url },
      ]
      image = "${module.ecr_repo.repo_url}"
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "${module.container_log_group.log_group_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "execution"
        }
      }
      portMappings = [
        {
          containerPort = local.container_port
        }
      ]
    }
  ])
  cpu                      = 256 # TODO variable
  execution_role_arn       = var.ecs_execution_role_arn
  memory                   = 512 # TODO variable
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.task_role.arn
}

## ALB, also NB the service role needs permission to write to the LB. see e.g. https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_UpdateService.html#API_UpdateService_RequestParameters
