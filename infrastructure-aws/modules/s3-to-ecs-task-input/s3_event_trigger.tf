resource "aws_s3_bucket_notification" "upload_bucket" {
  bucket      = module.upload_bucket.bucket_id
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "new_file_object" {
  name          = "${var.project_name}-${var.environment_name}-${var.process_name}-new-s3-object"
  description   = "A new object was created in the S3 ${module.upload_bucket.bucket_id} bucket"
  event_pattern = <<EOF
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "Object Created"
  ],
  "detail": {
    "bucket": {
        "name": ["${module.upload_bucket.bucket_id}"]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_task_using_file" {
  rule      = aws_cloudwatch_event_rule.new_file_object.name
  arn       = aws_sfn_state_machine.run_task_using_file.arn
  role_arn  = aws_iam_role.event_target_run_task_using_file.arn
  target_id = local.run_task_using_file_sfn_name
}

resource "aws_iam_role" "event_target_run_task_using_file" {
  name = "${var.project_name}-${var.environment_name}-${var.process_name}-target-run-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "event_target_run_task_using_file__invoke_run_task_sfn" {
  role       = aws_iam_role.event_target_run_task_using_file.id
  policy_arn = aws_iam_policy.start_run_task_using_file_sfn.arn
}
