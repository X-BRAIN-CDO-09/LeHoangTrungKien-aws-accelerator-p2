output "web_url" {
  description = "HTTP URL of the public EC2 web server."
  value       = "http://${module.compute.public_ip}"
}

output "ec2_public_ip" {
  description = "Public IP address of the web EC2 instance."
  value       = module.compute.public_ip
}

output "s3_assets_bucket" {
  description = "Private S3 bucket that stores static web assets."
  value       = module.storage.bucket_name
}

output "rds_endpoint" {
  description = "Private RDS MySQL endpoint."
  value       = module.database.endpoint
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for the RDS managed master password."
  value       = module.database.master_user_secret_arn
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

