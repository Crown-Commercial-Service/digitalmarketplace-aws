output "default_security_group_id" {
  description = "ID of the default security group for this VPC"
  value       = aws_vpc.vpc.default_security_group_id
}

output "private_subnet_ids" {
  description = "List of IDS of the private subnet(s)"
  value       = [aws_subnet.private.id]
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}
