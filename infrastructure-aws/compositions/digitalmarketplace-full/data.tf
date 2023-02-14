data "aws_iam_policy_document" "apprunner_service_deployment_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "apprunner:CreateService",
      "apprunner:CreateVpcIngressConnection",
      "apprunner:StartDeployment",
      "apprunner:ListServices"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "apprunner_deployment_jenkins_role_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.jenkins_account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}
