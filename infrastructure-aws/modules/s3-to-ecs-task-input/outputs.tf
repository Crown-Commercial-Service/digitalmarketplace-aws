output "upload_bucket_id" {
  description = "Full name of the bucket into which uploads should be performed"
  value       = module.upload_bucket.bucket_id
}
