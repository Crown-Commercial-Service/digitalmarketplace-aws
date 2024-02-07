resource "aws_s3_bucket" "lambda_dist" {
  bucket_prefix = "lambda-dist-assets"
  force_destroy = false
  tags = {
    Name = "lambda-dist-assets"
  }
}
