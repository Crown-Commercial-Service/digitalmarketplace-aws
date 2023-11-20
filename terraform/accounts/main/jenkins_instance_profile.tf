data "aws_iam_policy_document" "jenkins_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins-ci-IAMRole-1FIPDG9DE2CWJ"

  assume_role_policy = data.aws_iam_policy_document.jenkins_role.json
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ci-InstanceProfile-AOFDQ580SQSK"
  role = aws_iam_role.jenkins.id
}

data "aws_iam_policy_document" "jenkins_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = formatlist(
      "arn:aws:iam::%s:role/infrastructure",
      var.aws_sub_account_ids,
    )
  }

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = ["arn:aws:iam::${var.aws_main_account_id}:role/sops-credentials-access"]
  }

  statement {
    actions = [
      "codecommit:*",
    ]

    effect    = "Allow"
    resources = ["arn:aws:codecommit:eu-west-1:398263320410:*"]
  }

  statement {
    actions = [
      "codecommit:DeleteRepository",
    ]

    effect    = "Deny"
    resources = ["arn:aws:codecommit:eu-west-1:398263320410:*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    effect    = "Allow"
    resources = ["arn:aws:s3:::digitalmarketplace-deployment"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["arn:aws:s3:::digitalmarketplace-deployment/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = ["arn:aws:s3:::digitalmarketplace-database-backups"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = ["arn:aws:s3:::digitalmarketplace-database-backups/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cleaned-db-dumps",
      "arn:aws:s3:::digitalmarketplace-submissions-production-production",
      "arn:aws:s3:::digitalmarketplace-documents-production-production",
      "arn:aws:s3:::digitalmarketplace-documents-staging-staging",
      "arn:aws:s3:::digitalmarketplace-documents-preview-preview",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["arn:aws:s3:::digitalmarketplace-submissions-production-production/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cleaned-db-dumps/*",
      "arn:aws:s3:::digitalmarketplace-agreements-production-production/*",
      "arn:aws:s3:::digitalmarketplace-communications-production-production/*",
      "arn:aws:s3:::digitalmarketplace-communications-preview-preview/*",
      "arn:aws:s3:::digitalmarketplace-documents-production-production/*",
      "arn:aws:s3:::digitalmarketplace-documents-staging-staging/*",
      "arn:aws:s3:::digitalmarketplace-documents-preview-preview/*",
      "arn:aws:s3:::digitalmarketplace-reports-preview-preview/*",
      "arn:aws:s3:::digitalmarketplace-reports-staging-staging/*",
      "arn:aws:s3:::digitalmarketplace-reports-production-production/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucketVersions",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-agreements-production-production",
      "arn:aws:s3:::digitalmarketplace-agreements-staging-staging",
      "arn:aws:s3:::digitalmarketplace-agreements-preview-preview",
      "arn:aws:s3:::digitalmarketplace-submissions-production-production",
      "arn:aws:s3:::digitalmarketplace-submissions-staging-staging",
      "arn:aws:s3:::digitalmarketplace-submissions-preview-preview",
      "arn:aws:s3:::digitalmarketplace-communications-production-production",
      "arn:aws:s3:::digitalmarketplace-communications-staging-staging",
      "arn:aws:s3:::digitalmarketplace-communications-preview-preview",
      "arn:aws:s3:::digitalmarketplace-documents-production-production",
      "arn:aws:s3:::digitalmarketplace-documents-staging-staging",
      "arn:aws:s3:::digitalmarketplace-documents-preview-preview",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-cleaned-db-dumps/*",
    ]
  }
}

resource "aws_iam_role_policy" "jenkins" {
  name = "Jenkins"
  role = aws_iam_role.jenkins.id

  policy = data.aws_iam_policy_document.jenkins_policy.json
}

data "aws_iam_policy_document" "cloudwatch-logs-policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:398263320410:*",
    ]
  }
}

resource "aws_iam_role_policy" "jenkins-cloudwatch-logs" {
  name = "JenkinsCloudWatchLogs"
  role = aws_iam_role.jenkins.id

  policy = data.aws_iam_policy_document.cloudwatch-logs-policy.json
}

data "aws_iam_policy_document" "cloudwatch-metrics-policy" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "jenkins-cloudwatch-metrics" {
  name = "JenkinsCloudWatchMetrics"
  role = aws_iam_role.jenkins.id

  policy = data.aws_iam_policy_document.cloudwatch-metrics-policy.json
}

data "aws_iam_policy_document" "jenkins_assume_cloudtrail_validate_logs" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::${var.aws_main_account_id}:role/cloudtrail-validate-logs",
      "arn:aws:iam::${var.aws_prod_account_id}:role/cloudtrail-validate-logs",
      "arn:aws:iam::${var.aws_dev_account_id}:role/cloudtrail-validate-logs",
      "arn:aws:iam::${var.aws_backups_account_id}:role/cloudtrail-validate-logs",
    ]
  }
}

resource "aws_iam_role_policy" "jenkins_assume_cloudtrail_validate_logs" {
  name = "JenkinsAssumeCloudTrailValidateLogs"
  role = aws_iam_role.jenkins.id

  policy = data.aws_iam_policy_document.jenkins_assume_cloudtrail_validate_logs.json
}

resource "aws_iam_policy" "dmp_1_0_jenkins_cicd_infrastructure_role_policy" {
  name    = "dmp_1_0_jenkins_cicd_infrastructure_role_policy"
  policy  = data.aws_iam_policy_document.dmp_1_0_jenkins_cicd_infrastructure_role_policy.json
}

data "aws_iam_policy_document" "dmp_1_0_jenkins_cicd_infrastructure_role_policy" {
  statement {
    sid     = "Statement1"
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::${var.aws_sandbox_account_id}:role/cicd_infrastructure",
      "arn:aws:iam::${var.aws_dev_account_id}:role/cicd_infrastructure",
      "arn:aws:iam::${var.aws_staging_account_id}:role/cicd_infrastructure"
    ]
  }
}
