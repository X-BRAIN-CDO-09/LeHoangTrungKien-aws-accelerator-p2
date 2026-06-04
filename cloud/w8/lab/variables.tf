variable "aws_region" {
  description = "AWS region where the lab resources will be created."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Prefix used for resource names."
  type        = string
  default     = "k8s-alb-lab"
}

variable "instance_type" {
  description = "EC2 instance type for the single-node Kubernetes host."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH access."
  type        = string
  default     = null
}

variable "enable_ssh" {
  description = "Whether to open SSH access to the EC2 instance."
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH to the EC2 instance when enable_ssh is true."
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_node_port" {
  description = "Fixed NodePort and EC2 host port used by the ALB target group."
  type        = number
  default     = 30080

  validation {
    condition     = var.app_node_port >= 30000 && var.app_node_port <= 32767
    error_message = "app_node_port must be in the Kubernetes NodePort range: 30000-32767."
  }
}

variable "app_image_tag" {
  description = "Tag for the locally built demo app image pushed to ECR."
  type        = string
  default     = "v1"
}
