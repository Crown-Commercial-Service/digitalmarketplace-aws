resource "aws_iam_role" "instance_role" {
  name = "${var.project_name}-${var.environment_name}-${var.service_name}-instance-service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })
}
