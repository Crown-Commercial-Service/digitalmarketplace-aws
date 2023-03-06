resource "aws_ecs_cluster" "dmp" {
  name = "${var.project_name}-${var.environment_name}"
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "dmp_fargate" {
  cluster_name = aws_ecs_cluster.dmp.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name        = "${var.project_name}-${var.environment_name}-ecs-execution"
  description = "Role assumed by the ECS service during provision and setup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "pass_ecs_execution_role" {
  name = "${var.project_name}-${var.environment_name}-pass-ecs-execution-role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:GetRole",
          "iam:PassRole"
        ],
        Effect = "Allow",
        Resource = [
          aws_iam_role.ecs_execution_role.arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_execute__pass_task_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = module.buyer_frontend_service.pass_task_role_policy_arn
}
