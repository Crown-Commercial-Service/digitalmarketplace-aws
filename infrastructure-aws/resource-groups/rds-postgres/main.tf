resource "aws_db_subnet_group" "subnet_group" {
  name       = var.db_name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "db" {
  allocated_storage               = var.allocated_storage_gb
  allow_major_version_upgrade     = false
  backup_retention_period         = var.backup_retention_period_days
  db_name                         = var.db_name # Postgres dbnames use underscores, not hyphens
  db_subnet_group_name            = aws_db_subnet_group.subnet_group.name
  enabled_cloudwatch_logs_exports = ["postgresql"]
  engine                          = "postgres"
  engine_version                  = var.postgres_engine_version
  identifier                      = "${var.project_name}-${var.environment_name}" # Identifiers use hyphens, not underscores
  instance_class                  = var.db_instance_class
  multi_az                        = true
  password                        = var.db_password
  port                            = var.postgres_port
  publicly_accessible             = false
  skip_final_snapshot             = var.skip_final_snapshot
  storage_encrypted               = true
  username                        = var.db_username
  vpc_security_group_ids          = [aws_security_group.db.id]
}

resource "aws_security_group" "db" {
  name        = "${var.environment_name}-db"
  description = "RDS ${var.db_name} DB for ${var.project_name} ${var.environment_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment_name}-db"
  }
}

resource "aws_security_group" "db_clients" {
  name        = "${var.environment_name}-db-clients"
  description = "Entities permitted to access the ${var.project_name} ${var.environment_name} database"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment_name}-db-clients"
  }
}

resource "aws_security_group_rule" "db_postgres_in" {
  security_group_id = aws_security_group.db.id
  description       = "Allow ${var.postgres_port} inwards from db-clients SG"

  from_port                = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_clients.id
  to_port                  = var.postgres_port
  type                     = "ingress"
}

resource "aws_security_group_rule" "db_client_postgres_out" {
  security_group_id = aws_security_group.db_clients.id
  description       = "Allow ${var.postgres_port} from to db"

  from_port                = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  to_port                  = var.postgres_port
  type                     = "egress"
}

resource "aws_cloudwatch_log_group" "log" {
  # To apply retention policy to the automagically created db log group
  name              = "/aws/rds/instance/${aws_db_instance.db.identifier}/postgresql"
  retention_in_days = var.log_retention_period_days
}
