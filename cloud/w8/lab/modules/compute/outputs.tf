output "instance_id" {
  description = "ID of the EC2 Kubernetes host."
  value       = aws_instance.k8s.id
}

output "public_ip" {
  description = "Public IP of the EC2 Kubernetes host."
  value       = aws_instance.k8s.public_ip
}

output "ssm_role_name" {
  description = "IAM role used by the EC2 host to connect to Systems Manager."
  value       = aws_iam_role.ssm.name
}
