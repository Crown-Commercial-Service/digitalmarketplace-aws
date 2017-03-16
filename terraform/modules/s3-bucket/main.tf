resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::${var.access_account_id}:root"},
    "Action": "s3:PutObject",
    "Resource": "arn:aws:s3:::${var.bucket_name}/*"
  }]
}
EOF
}
