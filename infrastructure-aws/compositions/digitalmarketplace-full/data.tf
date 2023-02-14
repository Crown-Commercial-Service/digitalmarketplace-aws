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