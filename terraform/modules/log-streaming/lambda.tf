data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../../modules/log-streaming/src"
  output_path = "../../modules/log-streaming/lambda.zip"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.name}"
  role = "${aws_iam_role.lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "log_stream_lambda" {
  function_name    = "${var.name}"
  description      = "Stream CloudWatch Logs to Elasticsearch"
  filename         = "../../modules/log-streaming/lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "main.handler"
  runtime          = "nodejs8.10"
  memory_size      = 128
  timeout          = 10

  environment {
    variables = {
      ELASTICSEARCH_URL     = "${var.elasticsearch_url}"
      ELASTICSEARCH_API_KEY = "${var.elasticsearch_api_key}"
    }
  }
}
