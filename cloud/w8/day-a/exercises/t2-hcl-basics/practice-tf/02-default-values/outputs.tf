output "project_name" {
  description = "Project name provided from terraform.tfvars."
  value       = var.project_name
}

output "environment" {
  description = "Environment name currently used by Terraform, falling back to the default when not overridden."
  value       = var.environment
}

output "aws_region" {
  description = "AWS region provided from terraform.tfvars."
  value       = var.aws_region
}

output "backend_port" {
  description = "Backend port currently used by Terraform, falling back to the default when not overridden."
  value       = var.backend_port
}

output "health_check_path" {
  description = "Health check path currently used by Terraform, falling back to the default when not overridden."
  value       = var.health_check_path
}
