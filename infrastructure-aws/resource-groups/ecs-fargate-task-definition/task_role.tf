resource "aws_iam_role" "task_role" {
  name        = "${var.family_name}-ecs-task"
  description = "Role to be assumed by the ${var.family_name} container tasks in the service during general operation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:${var.aws_region}:${var.aws_target_account}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "pass_task_role" {
  name = "${var.family_name}-pass-task-role"
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
          aws_iam_role.task_role.arn
        ]
      }
    ]
  })
  depends_on = [
    aws_iam_role.task_role
  ]
}
