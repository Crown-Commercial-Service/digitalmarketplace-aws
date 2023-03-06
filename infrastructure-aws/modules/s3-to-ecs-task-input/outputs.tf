output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the ECS task role"
  value       = module.task_definition.pass_task_role_policy_document_json
}

output "upload_bucket_id" {
  description = "Full name of the bucket into which uploads should be performed"
  value       = module.upload_bucket.bucket_id
}

output "write_task_logs_policy_document_json" {
  description = "JSON describing an IAM policy which allows the ECS task logs to be written to"
  value       = module.task_log_group.write_log_group_policy_document_json
}
