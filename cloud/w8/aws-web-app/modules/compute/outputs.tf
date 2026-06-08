output "instance_id" {
  description = "EC2 web instance ID."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "EC2 web public IP."
  value       = aws_instance.web.public_ip
}

output "iam_role_name" {
  description = "IAM role used by the web instance."
  value       = aws_iam_role.web.name
}

