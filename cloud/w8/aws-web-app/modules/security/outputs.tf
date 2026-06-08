output "web_security_group_id" {
  description = "Web server security group ID."
  value       = aws_security_group.web.id
}

output "db_security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.db.id
}

