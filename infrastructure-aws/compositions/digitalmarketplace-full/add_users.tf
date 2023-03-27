/* Add new users by uploading a file to an S3 bucket.

   The format of the file should be as described here:
     https://github.com/Crown-Commercial-Service/digitalmarketplace-api/blob/main/scripts/add_users.py#L7
*/


module "dmp_add_users" {
  source = "../../modules/s3-to-ecs-task-input"

  api_clients_security_group_id = aws_security_group.api_clients.id # TODO pass all SGs in one list to avoid prescsriptive naming
  aws_region                    = var.aws_region
  aws_target_account            = var.aws_target_account
  /* For now, the existing (immutable) script requires the API access token to be passed on the command
     line. Hence is is being passed here. This will leak into logs and exeuction records for SFNs. However it should
     be borne in mind that the first thing the add_users.py script does anyway is to print to stdout the plaintext
     credentials currently being processed [ https://github.com/Crown-Commercial-Service/digitalmarketplace-api/blob/main/scripts/add_users.py#L28 ]
     so the cat is already out of the bag in terms of this POC's security.

     TODO Stop credentials leaks */
  container_command = [
    "/app/venv/bin/python3",
    "scripts/add_users.py",
    "http://${aws_lb.api.dns_name}",
    random_password.data_api_token.result
  ]
  container_environment_variables = [
    { "name" : "FLASK_APP", "value" : "application:application" }
  ]
  container_memory                   = var.services_container_memories[local.service_name_api] # Use the API memory settings
  ecr_repo_url                       = module.api_service.ecr_repo_url                         # Use the API codebase
  ecs_cluster_arn                    = aws_ecs_cluster.dmp.arn
  ecs_execution_role_arn             = aws_iam_role.ecs_execution_role.arn
  egress_all_security_group_id       = aws_security_group.egress_all.id # TODO pass all SGs in one list to avoid prescsriptive naming
  environment_name                   = var.environment_name
  is_ephemeral                       = var.environment_is_ephemeral
  lambda_bucket_id                   = var.lambda_bucket_id
  pass_ecs_execution_role_policy_arn = aws_iam_policy.pass_ecs_execution_role.arn
  secret_environment_variables = [
    { "name" : "VCAP_SERVICES", "valueFrom" : aws_secretsmanager_secret.db_creds_vcap.arn }
  ]
  subnet_ids   = module.dmp_vpc.private_subnet_ids
  process_name = "add-users"
  project_name = var.project_name
  vpc_id       = module.dmp_vpc.vpc_id
}
