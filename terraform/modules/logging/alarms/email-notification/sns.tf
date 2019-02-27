// Create topic
resource "aws_sns_topic" "alarm_email_topic" {
  name = "${var.name}-alarm-email"
}

// Policy enforcing
//  * Only GDS emails can subscribe and recieve messages
//  * Subscribers can only subscribe to emails
//  * Only our account entities can manage this topic and trigger emails

data "aws_iam_policy_document" "alarm_email_topic_policy_document" {
  policy_id = "alarm-email-topic-policy-document"

  // Management rules statement

  statement {
    sid    = "topic_permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

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

    resources = [
      "${aws_sns_topic.alarm_email_topic.arn}",
    ]
  }

  // Subscription rules statement

  statement {
    sid    = "email_only_and_gds_only"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
    ]

    condition {
      variable = "SNS:Protocol"
      test     = "StringEquals"

      values = [
        "email",
        "email-json",
      ]
    }

    condition {
      variable = "SNS:Endpoint"
      test     = "StringLike"

      values = [
        "*@gds.slack.com",
        "*@digital.cabinet-office.gov.uk",
      ]
    }

    resources = [
      "${aws_sns_topic.alarm_email_topic.arn}",
    ]
  }
}

resource "aws_sns_topic_policy" "alarm_email_topic_policy" {
  arn = "${aws_sns_topic.alarm_email_topic.arn}"

  policy = "${data.aws_iam_policy_document.alarm_email_topic_policy_document.json}"
}

// The below is unsupported but describes the subscription of a slack email to the topic
// https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email
//
//resource "aws_sns_topic_subscription" "slack_dm_2nd_line_email_subscription_to_topic" {
//  topic_arn = "${aws_sns_topic.slack_dm_2nd_line_email.arn}"
//  protocol  = "email"
//  endpoint  = "${var.email_address}"
//}

