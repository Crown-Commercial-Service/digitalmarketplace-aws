# Backups role, policy and role-policy attachment
resource "aws_iam_role" "backups_role" {
  name = "backups"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_main_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "backups_policy" {
  name = "backups-access-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Resource": "arn:aws:s3:::*",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::digitalmarketplace-database-backups",
        "arn:aws:s3:::digitalmarketplace-cross-region-database-backups"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::digitalmarketplace-database-backups/*",
        "arn:aws:s3:::digitalmarketplace-cross-region-database-backups/*"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": true
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "backups_role_policy_attachment" {
  role       = aws_iam_role.backups_role.id
  policy_arn = aws_iam_policy.backups_policy.arn
}

# Replication role, policy and role-policy attachment
# Only S3 service can assume this role and perform these actions.
# (See https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#using-replication-configuration)
resource "aws_iam_role" "replication_role" {
  name = "replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY

}

resource "aws_iam_policy" "replication_policy" {
  name = "replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups"
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::digitalmarketplace-database-backups/*"
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::digitalmarketplace-cross-region-database-backups/*"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication_role.id
  policy_arn = aws_iam_policy.replication_policy.arn
}

