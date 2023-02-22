module "dmp_db" {
  source = "../../resource-groups/rds-postgres"

  db_name          = "${var.project_name}_${var.environment_name}" # PostgreSQL uses underscores not hyphens
  db_password      = aws_secretsmanager_secret_version.dmp_db_password.secret_string
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
