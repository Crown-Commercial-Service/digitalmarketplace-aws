resource "aws_iam_role" "sns_success_feedback" {
  name = "sns_success_feedback_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sns_success_feedback_sns_feedback" {
  role       = "${aws_iam_role.sns_success_feedback.name}"
  policy_arn = "${aws_iam_policy.sns_feedback.arn}"
}

resource "aws_iam_role" "sns_failure_feedback" {
  name = "sns_failure_feedback_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sns_failure_feedback_sns_feedback" {
  role       = "${aws_iam_role.sns_failure_feedback.name}"
  policy_arn = "${aws_iam_policy.sns_feedback.arn}"
}

resource "aws_iam_policy" "sns_feedback" {
  name = "sns_feedback"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:PutMetricFilter",
              "logs:PutRetentionPolicy"
          ],
          "Resource": [
              "*"
          ]
      }
  ]
}
EOF
}

data "aws_iam_policy_document" "s3_file_upload_notification_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "sns_permissions"

    actions = [
      "SNS:Publish",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:Receive",
      "SNS:AddPermission",
      "SNS:Subscribe",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${var.account_id}",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.s3_file_upload_notification.arn}",
    ]
  }

  statement {
    sid = "sns_https_only"

    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
    ]

    condition {
      test     = "StringEquals"
      variable = "SNS:Protocol"

      values = [
        "https",
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.s3_file_upload_notification.arn}",
    ]
  }

  statement {
    sid = "s3_bucket_notification_sns_permission"

    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:s3:::${var.bucket_ids[0]}",
        "arn:aws:s3:::${var.bucket_ids[1]}",
        "arn:aws:s3:::${var.bucket_ids[2]}",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.s3_file_upload_notification.arn}",
    ]
  }
}
