output "endpoint" {
  description = "RDS endpoint including port."
  value       = aws_db_instance.mysql.endpoint
}

output "address" {
  description = "RDS hostname."
  value       = aws_db_instance.mysql.address
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.mysql.port
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN for the RDS managed master password."
  value       = try(aws_db_instance.mysql.master_user_secret[0].secret_arn, null)
}

