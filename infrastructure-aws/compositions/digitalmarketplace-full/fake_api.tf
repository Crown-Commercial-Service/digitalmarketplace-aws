/* API faker to allow frontend service to at least start up.

   Everything is self-contained in this file because we will be removing
   all of these resources as the POC matures.
*/

locals {
  deploy_object_key   = "${local.function_name}.zip"
  fake_api_deploy_zip = "${path.module}/fake_api_lambda.zip"
  function_name       = "${var.project_name}-${var.environment_name}-fake-api"
}

data "archive_file" "fake_api_deploy_zip" {
  type        = "zip"
  source_dir  = "${path.module}/fake_api_lambda_src"
  output_path = local.fake_api_deploy_zip
}

resource "aws_s3_bucket" "lambda_deploy" {
  bucket = "${var.project_name}-${var.environment_name}-lambda-deploy"
}

resource "aws_s3_bucket_acl" "lambda_deploy" {
  bucket = aws_s3_bucket.lambda_deploy.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "lambda_deploy" {
  bucket = aws_s3_bucket.lambda_deploy.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_deploy" {
  bucket                  = aws_s3_bucket.lambda_deploy.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "fake_api_deploy_object" {
  bucket = aws_s3_bucket.lambda_deploy.id

  key    = local.deploy_object_key
  source = local.fake_api_deploy_zip

  etag = filemd5(data.archive_file.fake_api_deploy_zip.output_path)
}

resource "aws_lambda_function" "fake_api" {
  function_name = local.function_name

  s3_bucket = aws_s3_bucket.lambda_deploy.id
  s3_key    = local.deploy_object_key

  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.fake_api_deploy_zip.output_base64sha256

  role = aws_iam_role.fake_api_lambda.arn
}

resource "aws_lambda_function_url" "fake_api" {
  function_name      = aws_lambda_function.fake_api.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "log" {
  # To apply retention policy to the automagically created log group
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "fake_api_lambda" {
  name = "${var.project_name}-${var.environment_name}-fake-api-lambda-service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fake_api_lambda__lambda_basic" {
  role = aws_iam_role.fake_api_lambda.name
  # Just the plain AWS-managed policy for this temporary resource
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
