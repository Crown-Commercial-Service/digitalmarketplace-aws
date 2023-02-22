resource "aws_ecs_task_definition" "task" {
  family = var.family_name
  container_definitions = jsonencode([
    {
      name        = var.container_name
      environment = var.container_environment_variables

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
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
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
}
