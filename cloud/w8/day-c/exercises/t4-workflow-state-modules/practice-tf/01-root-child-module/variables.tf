variable "project_name" {
  description = "Root project name used for naming examples."
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the provider."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will run."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs attached to the instance."
  type        = list(string)
}

variable "key_name" {
  description = "Optional key pair name for SSH access."
  type        = string
  default     = null
}
