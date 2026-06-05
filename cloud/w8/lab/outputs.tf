output "alb_url" {
  description = "Public URL of the demo app exposed by the ALB."
  value       = "http://${module.alb.dns_name}"
}

output "app_image" {
  description = "Public Docker image deployed into Kubernetes."
  value       = var.app_image
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 Kubernetes host."
  value       = module.compute.public_ip
}

output "node_port" {
  description = "EC2 host port forwarded to the Kubernetes NodePort service."
  value       = var.app_node_port
}

output "generated_private_key_pem" {
  description = "Generated EC2 private key. Use only when enable_ssh is true and key_name is not set."
  value       = tls_private_key.ec2.private_key_openssh
  sensitive   = true
}

output "generated_private_key_path" {
  description = "Local path where the generated EC2 private key is written."
  value       = local_sensitive_file.generated_private_key.filename
  sensitive   = true
}
