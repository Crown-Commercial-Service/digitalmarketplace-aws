resource "aws_sfn_state_machine" "run_task_using_file" {
  name     = local.run_task_using_file_sfn_name
  role_arn = aws_iam_role.sfn_run_task_using_file.arn

  definition = <<EOF
{
  "Comment": "Run an ECS task against a file uploaded to S3: ${var.process_name}",
  "StartAt": "Copy S3 object to EFS",
  "States": {
    "Copy S3 object to EFS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${module.copy_s3_to_efs_lambda.function_arn}",
        "Payload": {
          "from_bucket.$": "$$.Execution.Input.detail.bucket.name",
          "from_key.$": "$$.Execution.Input.detail.object.key",
          "to_folder": "${local.fs_local_mount_path}"
        }
      },
      "ResultSelector": {
        "ecs_filename.$": "$.Payload.to_filename"
      },
      "ResultPath": "$",
      "Next": "Delete S3 object"
    },
    "Delete S3 object": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:s3:deleteObject",
      "Parameters": {
        "Bucket.$": "$$.Execution.Input.detail.bucket.name",
        "Key.$": "$$.Execution.Input.detail.object.key"
      },
      "End": true
    }
  }
}
EOF
}
resource "aws_iam_policy" "start_run_task_using_file_sfn" {
  name = "${var.project_name}-${var.environment_name}-${var.process_name}-start-sfn"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution",
        ]
        Effect   = "Allow"
        Resource = aws_sfn_state_machine.run_task_using_file.arn
      }
    ]
  })
}

resource "aws_iam_role" "sfn_run_task_using_file" {
  name = "${var.project_name}-${var.environment_name}-${var.process_name}-sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "run_task_using_file__invoke_copy_lambda" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = module.copy_s3_to_efs_lambda.invoke_lambda_iam_policy_arn
}

resource "aws_iam_role_policy_attachment" "run_task_using_file__delete_upload_object" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = module.upload_bucket.delete_object_iam_policy_arn
}
