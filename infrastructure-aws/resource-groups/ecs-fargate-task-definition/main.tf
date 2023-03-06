locals {
  efs_mount_config_as_set = var.efs_mount_config == null ? [] : [var.efs_mount_config]
}

resource "aws_ecs_task_definition" "task" {
  family = var.family_name
  container_definitions = jsonencode([
    {
      name        = var.container_name
      command     = var.override_command # If null, does not override Dockerfile original command
      environment = var.container_environment_variables
      essential   = true
      healthCheck = var.container_healthcheck_command == null ? null : {
        command     = ["CMD-SHELL", var.container_healthcheck_command]
        startPeriod = 10
        timeout     = 10
      }

      image = var.ecr_repo_url
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : var.container_log_group_name,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : "execution"
        }
      }

      mountPoints = var.efs_mount_config == null ? null : [
        {
          "containerPath" : var.efs_mount_config["mount_point"],
          "readOnly" : true,
          "sourceVolume" : var.efs_mount_config["volume_name"]
        }
      ]

      portMappings = var.container_port == null ? null : [
        {
          containerPort = var.container_port
        }
      ]
      secrets = var.secret_environment_variables
    }
  ])
  cpu                      = var.container_cpu
  execution_role_arn       = var.ecs_execution_role_arn
  memory                   = var.container_memory
  network_mode             = "awsvpc" # Fixed for Fargate
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  task_role_arn = aws_iam_role.task_role.arn

  dynamic "volume" {
    for_each = local.efs_mount_config_as_set # Zero or one elements only
    iterator = efs_config

    content {
      efs_volume_configuration {
        authorization_config {
          access_point_id = efs_config.value["access_point_id"]
          iam             = "DISABLED"
        }
        file_system_id     = efs_config.value["file_system_id"]
        transit_encryption = "ENABLED"
      }

      name = efs_config.value["volume_name"]
    }
  }
}


