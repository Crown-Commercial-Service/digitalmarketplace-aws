/* Create Zip file archives for all Lambda source online once (here)
   rather than at submodule level*/

locals {
  # { function_base_name: source_folder_relative_path }
  lambdas = {
    "copy-s3-to-efs" : "../../modules/s3-to-ecs-task-input/lambdas/copy-s3-to-efs"
    "delete-from-efs" : "../../modules/s3-to-ecs-task-input/lambdas/delete-from-efs"
  }
  lambdazips_folder = "../../lambdazips"
}

data "archive_file" "lambda_zip" {
  for_each    = local.lambdas
  type        = "zip"
  source_dir  = each.value
  output_path = "${local.lambdazips_folder}/${each.key}.zip"
}
