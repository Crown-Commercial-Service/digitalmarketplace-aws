module "dmp_db" {
  source = "../../resource-groups/rds-postgres"

  db_name          = local.db_name
  db_password      = aws_secretsmanager_secret_version.dmp_db_password.secret_string
  db_username      = local.db_username
  environment_name = var.environment_name
  project_name     = var.project_name
  subnet_ids       = module.dmp_vpc.private_subnet_ids
  vpc_id           = module.dmp_vpc.vpc_id
}

resource "random_password" "dmp_db" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "dmp_db_password" {
  name        = "${var.project_name}-${var.environment_name}-db-password"
  description = "Auto-generated password for the PostgreSQL database"
}

resource "aws_secretsmanager_secret_version" "dmp_db_password" {
  secret_id     = aws_secretsmanager_secret.dmp_db_password.id
  secret_string = random_password.dmp_db.result
}

/* Db creds are delivered to the container via the CF convention of a "VCAP_SERVICES" environment
   variable. We therefore have to construct this fully in advance and store it as a secret.
*/
resource "aws_secretsmanager_secret" "db_creds_vcap" {
  name        = "${var.project_name}-${var.environment_name}-db-creds-vcap"
  description = "Sensitive VCAP_SERVICES db creds environment variable"
}

locals {
  vcap_json = "{\"postgres\": [{\"name\": \"postgres\", \"credentials\": {\"uri\": \"${local.db_connect_uri}\"}}]}"
}

resource "aws_secretsmanager_secret_version" "db_creds_vcap" {
  secret_id     = aws_secretsmanager_secret.db_creds_vcap.id
  secret_string = local.vcap_json
}

resource "aws_iam_policy" "read_db_creds_vcap_secret" {
  name = "${var.project_name}-db-creds-vcap-read-secret"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_creds_vcap.arn
        ]
      }
    ]
  })
}

# Secrets read at startup - Execution role needs access (rather than task role)
resource "aws_iam_role_policy_attachment" "execution_role__read_vcap_secret" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.read_db_creds_vcap_secret.arn
}
