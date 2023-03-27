module "upload_bucket" {
  source       = "../../resource-groups/private-s3-bucket"
  bucket_name  = "${var.project_name}-${var.environment_name}-${var.process_name}"
  is_ephemeral = var.is_ephemeral
}
