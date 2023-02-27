output "bucket_arn" {
  description = "ARN of created bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_id" {
  description = "Full name of created bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_regional_domain_name" {
  description = "The bucket domain name including the region name"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "delete_object_iam_policy_arn" {
  description = "ARN of the IAM Policy which permits DeleteObject on this bucket's objects"
  value       = aws_iam_policy.delete_object.arn
}

output "get_object_iam_policy_arn" {
  description = "ARN of the IAM Policy which permits GetObject on this bucket's objects"
  value       = aws_iam_policy.get_object.arn
}

output "putt_object_iam_policy_arn" {
  description = "ARN of the IAM Policy which permits PutObject on this bucket's objects"
  value       = aws_iam_policy.put_object.arn
}
