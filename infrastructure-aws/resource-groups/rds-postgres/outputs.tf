output "db_access_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the DB"
  value       = aws_security_group.db_clients.id
}

output "rds_db_endpoint" {
  description = "Endpoint to which to connect for access to this database"
  value       = aws_db_instance.db.endpoint
}
