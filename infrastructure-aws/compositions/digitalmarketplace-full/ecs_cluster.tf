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

data "aws_iam_policy_document" "ecs_execution_pass_task_permissions" {
  source_policy_documents = [
    module.buyer_frontend_service.pass_task_role_policy_document_json
  ]
}

resource "aws_iam_policy" "ecs_execution_pass_task_permissions" {
  name   = "${var.project_name}-${var.environment_name}-ecs-execution-pass-task-permissions"
  policy = data.aws_iam_policy_document.ecs_execution_pass_task_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs_execute__ecs_execution_pass_task_permissions" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_pass_task_permissions.arn
}

data "aws_iam_policy_document" "ecs_execution_log_permissions" {
  override_policy_documents = [ # override because we expect repeat Sids for some statements
    # core services
    module.api_service.write_container_logs_policy_document_json,
    module.buyer_frontend_service.write_container_logs_policy_document_json,
    module.user_frontend_service.write_container_logs_policy_document_json,

    # one-off tasks
    module.dmp_add_users.write_task_logs_policy_document_json,
    module.migration_log_group.write_log_group_policy_document_json
  ]
}

resource "aws_iam_policy" "ecs_execution_log_permissions" {
  name   = "${var.project_name}-${var.environment_name}-ecs-execution-log-permissions"
  policy = data.aws_iam_policy_document.ecs_execution_log_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs_execute__ecs_execution_log_permissions" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_log_permissions.arn
}
