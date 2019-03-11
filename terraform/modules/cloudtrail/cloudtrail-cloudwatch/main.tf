resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "${var.trail_name}-cloudtrail-log-group"
  retention_in_days = "${var.retention_in_days}"
}

# When this policy is attached to a role as an assume_role_policy the aws cloudtrail service can assume the role
data "aws_iam_policy_document" "cloudtrail_assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "create_cloudtrail_logs_in_cloudwatch_cloudtrail_log_group_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}",
    ]
  }
}

resource "aws_iam_policy" "create_cloudtrail_logs_in_cloudwatch_cloudtrail_log_group_policy" {
  name        = "create-logs-in-${var.trail_name}-cloudtrail-log-group"
  description = "Create logs in the ${var.trail_name}-cloudtrail-log-group Log Group in CloudWatch"
  policy      = "${data.aws_iam_policy_document.create_cloudtrail_logs_in_cloudwatch_cloudtrail_log_group_policy_document.json}"
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch_role" {
  name = "CloudTrail_CloudWatchLogs_Role"

  assume_role_policy = "${data.aws_iam_policy_document.cloudtrail_assume_role_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "attach_create_logs_in_log_group_to_cloudtrail_to_cloudwatch_role" {
  role       = "${aws_iam_role.cloudtrail_to_cloudwatch_role.name}"
  policy_arn = "${aws_iam_policy.create_cloudtrail_logs_in_cloudwatch_cloudtrail_log_group_policy.arn}"
}
