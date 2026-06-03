/*
TODO:
- Expose values returned by the child module.
- Use module.ec2.<output_name>.
*/

output "instance_id" {
  description = "EC2 instance ID returned by the child module."
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public IP address returned by the child module."
  value       = module.ec2.public_ip
}

output "private_ip" {
  description = "Private IP address returned by the child module."
  value       = module.ec2.private_ip
}
