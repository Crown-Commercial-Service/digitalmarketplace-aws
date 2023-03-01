module "copy_s3_to_efs_lambda" {
  source             = "../../resource-groups/deployed-lambda"
  environment_name   = var.environment_name
  function_base_name = "copy-s3-to-efs"
  lambda_bucket_id   = var.lambda_bucket_id
  handler            = "lambda_function.lambda_handler"
  security_group_ids = [
    aws_security_group.filesystem_clients.id,
    var.egress_all_security_group_id
  ]
  subnet_ids = var.subnet_ids

  file_system_config = {
    "efs_access_point_arn" : aws_efs_access_point.access.arn,
    "local_mount_path" : local.fs_local_mount_path
  }

  depends_on = [
    aws_efs_mount_target.target
  ]
}

resource "aws_iam_role_policy_attachment" "copy_s3_to_efs_lambda__get_upload_object" {
  role       = module.copy_s3_to_efs_lambda.service_role_name
  policy_arn = module.upload_bucket.get_object_iam_policy_arn
}
