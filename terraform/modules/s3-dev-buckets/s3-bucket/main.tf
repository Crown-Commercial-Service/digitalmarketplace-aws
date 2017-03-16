resource "aws_s3_bucket" "s3_bucket" {
  bucket = "digitalmarketplace-${var.s3_bucket_name}-dev-dev"
  acl = "private"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
        "Principal": {
           "AWS": "arn:aws:iam::${var.aws_main_account_id}:root"
        },
        "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::digitalmarketplace-${var.s3_bucket_name}-dev-dev"
      },
      {
        "Principal": {
           "AWS": "arn:aws:iam::${var.aws_main_account_id}:root"
        },
        "Action": [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::digitalmarketplace-${var.s3_bucket_name}-dev-dev/*"
      }
   ]
}
EOF
}
