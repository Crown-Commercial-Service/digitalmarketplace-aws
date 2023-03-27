locals {
  file_system_config_as_set = var.file_system_config == null ? [] : [var.file_system_config]
  function_full_name        = "${var.environment_name}-${var.function_base_name}"
  lambdazips_folder         = "../../lambdazips"
  zipfile_name              = "${var.function_base_name}.zip" # Taking a generically-titled source zip which may be repeated across module invocations
}

resource "aws_s3_object" "deploy_object" {
  bucket        = var.lambda_bucket_id
  force_destroy = var.is_ephemeral
  key           = local.zipfile_name
  source        = "${local.lambdazips_folder}/${local.zipfile_name}"

  etag = filemd5("${local.lambdazips_folder}/${local.zipfile_name}")
}

resource "aws_lambda_function" "function" {
  function_name = local.function_full_name

  s3_bucket = var.lambda_bucket_id
  s3_key    = local.zipfile_name

  runtime     = var.runtime
  handler     = var.handler
  timeout     = var.timeout_seconds
  memory_size = var.runtime_memory_size

  source_code_hash = filebase64sha256("${local.lambdazips_folder}/${local.zipfile_name}")

  role = aws_iam_role.lambda_exec.arn

  dynamic "file_system_config" {
    for_each = local.file_system_config_as_set # Zero or one elements only
    iterator = fs_config
    content {
      arn              = fs_config.value["efs_access_point_arn"]
      local_mount_path = fs_config.value["local_mount_path"]
    }
  }

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  depends_on = [
    aws_s3_object.deploy_object
  ]
}

resource "aws_iam_policy" "invoke_lambda" {
  name = "lambda-invoke-${local.function_full_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.function.arn
      }
    ]
  })
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.function_full_name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com" // TODO Limit the actor
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
