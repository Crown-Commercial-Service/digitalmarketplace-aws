/* The Nginx server baked into each frontend service requires a
   basic auth header to allow access to `/` and beyond. This is
   stored in Secrets Manager as a matter of best practice.

   See "Pre-requisites" section of main infrastructure README.md
   for information on how to set this up.
*/

data "aws_secretsmanager_secret" "proxy_credentials" {
  name = "${var.project_name}-${var.environment_name}-proxy-credentials"
}

data "aws_secretsmanager_secret_version" "proxy_credentials" {
  secret_id = data.aws_secretsmanager_secret.proxy_credentials.id
}

locals {
  proxy_credentials_data = jsondecode(
    data.aws_secretsmanager_secret_version.proxy_credentials.secret_string
  )
  proxy_credentials_htpasswd_string = local.proxy_credentials_data["htpasswd_string"]
  proxy_credentials                 = "${local.proxy_credentials_data["auth_user"]}:${local.proxy_credentials_data["auth_password"]}"
}
