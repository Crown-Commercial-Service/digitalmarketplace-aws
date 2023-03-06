# TODO Fix horrible literal array exposion in state "Run and wait for ECS task".Parameters.NetworkConfiguration.Subnets AND "Run and wait for ECS task"..Overrides.ContainerOverrides.Command
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
      "Next": "Run and wait for ECS task"
    },
    "Run and wait for ECS task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "${var.ecs_cluster_arn}",
        "TaskDefinition": "${module.task_definition.task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
             "AssignPublicIp": "DISABLED",
             "SecurityGroups.$": "States.Array('${aws_security_group.filesystem_clients.id}', '${var.egress_all_security_group_id}', '${var.api_clients_security_group_id}')",
             "Subnets.$": "States.Array('${var.subnet_ids[0]}', '${var.subnet_ids[1]}')"
          }
        },
        "Overrides": {
            "ContainerOverrides": [
                {
                    "Name": "${var.process_name}",
                    "Command.$": "States.Array('${var.container_command[0]}', '${var.container_command[1]}', '${var.container_command[2]}', '${var.container_command[3]}', States.Format('${local.fs_local_mount_path}/{}', $.ecs_filename))"
                }
            ]
        }
      },
      "ResultPath": null,
      "Next": "Delete file from EFS"
    },
    "Delete file from EFS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${module.delete_from_efs_lambda.function_arn}",
        "Payload": {
          "filename.$": "$.ecs_filename",
          "from_folder": "${local.fs_local_mount_path}"
        }
      },
      "ResultPath": null,
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

  depends_on = [
    # These policies are needed _at Terraform apply time_ hence the explicit dependency
    aws_iam_role_policy_attachment.run_task_using_file__managed_rules,
    aws_iam_role_policy_attachment.run_task_using_file__pass_ecs_execution_role
  ]
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

resource "aws_iam_role_policy_attachment" "run_task_using_file__pass_ecs_execution_role" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = var.pass_ecs_execution_role_policy_arn
}

# Required for the ".sync" falvour of ECS runTask invocation
resource "aws_iam_policy" "manage_ecs_and_events" {
  name = "${var.project_name}-${var.environment_name}-${var.process_name}-manage-ecs-and-events"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask"
        ]
        Effect = "Allow"
        Resource = [
          "${module.task_definition.task_definition_arn}"
        ]
      },
      {
        Action = [
          "ecs:DescribeTasks",
          "ecs:StopTask"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "events:DescribeRule",
          "events:PutRule",
          "events:PutTargets"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:events:${var.aws_region}:${var.aws_target_account}:rule/StepFunctionsGetEventsForECSTaskRule"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "run_task_using_file__managed_rules" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = aws_iam_policy.manage_ecs_and_events.arn
}

resource "aws_iam_role_policy_attachment" "run_task_using_file__invoke_copy_lambda" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = module.copy_s3_to_efs_lambda.invoke_lambda_iam_policy_arn
}

resource "aws_iam_role_policy_attachment" "run_task_using_file__invoke_delete_lambda" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = module.delete_from_efs_lambda.invoke_lambda_iam_policy_arn
}

resource "aws_iam_role_policy_attachment" "run_task_using_file__delete_upload_object" {
  role       = aws_iam_role.sfn_run_task_using_file.id
  policy_arn = module.upload_bucket.delete_object_iam_policy_arn
}
