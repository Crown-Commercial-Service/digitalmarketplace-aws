resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = var.is_ephemeral
}

resource "aws_iam_policy" "get_object" {
  name = "${var.bucket_name}-get-s3-object"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "delete_object" {
  name = "${var.bucket_name}-delete-s3-object"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "put_object" {
  name = "${var.bucket_name}-put-s3-object"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aes_encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
