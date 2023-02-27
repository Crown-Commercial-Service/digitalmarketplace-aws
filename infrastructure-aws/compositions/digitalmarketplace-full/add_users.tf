/* Add new users by uploading a file to an S3 bucket.

   The format of the file should be as described here:
     https://github.com/Crown-Commercial-Service/digitalmarketplace-api/blob/main/scripts/add_users.py#L7
*/


module "dmp_add_users" {
  source = "../../modules/s3-to-ecs-task-input"

  environment_name = var.environment_name
  process_name     = "add-users"
  project_name     = var.project_name
}
