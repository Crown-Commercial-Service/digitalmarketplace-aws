resource "aws_iam_role" "jenkins" {
  name = "jenkins-ci-IAMRole-1FIPDG9DE2CWJ"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ci-InstanceProfile-AOFDQ580SQSK"
  role = "${aws_iam_role.jenkins.id}"
}

resource "aws_iam_role_policy" "jenkins" {
  name = "Jenkins"
  role = "${aws_iam_role.jenkins.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [${join(",", formatlist("\"arn:aws:iam::%s:role/infrastructure\"", var.aws_sub_account_ids))}]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.aws_main_account_id}:role/sops-credentials-access"
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::digitalmarketplace-deployment"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-deployment/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::digitalmarketplace-submissions-production-production",
        "arn:aws:s3:::digitalmarketplace-documents-production-production",
        "arn:aws:s3:::digitalmarketplace-documents-staging-staging",
        "arn:aws:s3:::digitalmarketplace-documents-preview-preview"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::digitalmarketplace-submissions-production-production/*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectAcl"
        ],
        "Resource": [
          "arn:aws:s3:::digitalmarketplace-agreements-production-production/*",
          "arn:aws:s3:::digitalmarketplace-communications-production-production/*",
          "arn:aws:s3:::digitalmarketplace-communications-preview-preview/*",
          "arn:aws:s3:::digitalmarketplace-documents-production-production/*",
          "arn:aws:s3:::digitalmarketplace-documents-staging-staging/*",
          "arn:aws:s3:::digitalmarketplace-documents-preview-preview/*",
          "arn:aws:s3:::digitalmarketplace-reports-preview-preview/*",
          "arn:aws:s3:::digitalmarketplace-reports-staging-staging/*",
          "arn:aws:s3:::digitalmarketplace-reports-production-production/*"
        ]
    }
  ]
}
EOF
}
