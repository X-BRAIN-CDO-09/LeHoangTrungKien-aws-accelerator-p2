variable "name_prefix" {
  description = "Prefix used for security group names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups are created."
  type        = string
}

variable "app_node_port" {
  description = "NodePort exposed on the EC2 host."
  type        = number
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
