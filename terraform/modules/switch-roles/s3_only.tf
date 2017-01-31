resource "aws_iam_role" "s3_only" {
  name = "s3-only"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.source_aws_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_only" {
  name = "S3Only"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*-dev-dev"
      ]
    },
    {
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*-dev-dev/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_only_ip_restriced_access" {
  role = "${aws_iam_role.s3_only.name}"
  policy_arn = "${var.ip_restricted_access_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "s3_only_s3_only" {
  role = "${aws_iam_role.s3_only.name}"
  policy_arn = "${aws_iam_policy.s3_only.arn}"
}
