output "vpc_id" {
  description = "ID of the vpc"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}
output "frontend_sg_id" {
  description = "Frontend security group ID"
  value       = aws_security_group.frontend.id
}

output "backend_sg_id" {
  description = "Backend security group ID"
  value       = aws_security_group.backend.id
}

output "database_sg_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}