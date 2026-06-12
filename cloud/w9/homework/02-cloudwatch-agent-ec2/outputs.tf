output "instance_id" {
  description = "EC2 instance ID created for the CloudWatch Agent homework."
  value       = aws_instance.cloudwatch_agent.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance."
  value       = aws_instance.cloudwatch_agent.public_ip
}

output "iam_role_name" {
  description = "IAM role attached to the EC2 instance."
  value       = aws_iam_role.ec2_cloudwatch_agent.name
}

output "ssm_start_session_command" {
  description = "Command to connect to the instance by Session Manager."
  value       = "aws ssm start-session --target ${aws_instance.cloudwatch_agent.id} --region ${var.aws_region}"
}

output "cloudwatch_agent_status_command" {
  description = "Command to verify CloudWatch Agent status after connecting with SSM."
  value       = "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status"
}

