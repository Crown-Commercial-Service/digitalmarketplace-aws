/* Add new users by uploading a file to an S3 bucket.

   The format of the file should be as described here:
     https://github.com/Crown-Commercial-Service/digitalmarketplace-api/blob/main/scripts/add_users.py#L7
*/


module "dmp_add_users" {
  source = "../../modules/s3-to-ecs-task-input"

  egress_all_security_group_id = aws_security_group.egress_all.id
  environment_name             = var.environment_name
  lambda_bucket_id             = var.lambda_bucket_id
  subnet_ids                   = module.dmp_vpc.private_subnet_ids
  process_name                 = "add-users"
  project_name                 = var.project_name
  vpc_id                       = module.dmp_vpc.vpc_id
}
