variable "name_prefix" {
  description = "Prefix used for ALB resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the target group is created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs attached to the ALB."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB."
  type        = string
}

variable "target_instance_id" {
  description = "EC2 instance ID registered in the target group."
  type        = string
}

variable "app_node_port" {
  description = "NodePort exposed on the EC2 host."
  type        = number
}
