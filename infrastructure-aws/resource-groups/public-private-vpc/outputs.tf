output "default_security_group_id" {
  description = "ID of the default security group for this VPC"
  value       = aws_vpc.vpc.default_security_group_id
}

output "private_subnet_ids" {
  description = "List of IDS of the private subnet(s)"
  value       = [for s in aws_subnet.private : "${s.id}"]
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}
