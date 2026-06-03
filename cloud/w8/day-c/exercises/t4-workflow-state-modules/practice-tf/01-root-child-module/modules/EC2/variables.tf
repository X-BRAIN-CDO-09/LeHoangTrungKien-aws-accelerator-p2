variable "project_name" {
  description = "Project name passed from the root module."
  type        = string
}

variable "environment" {
  description = "Environment name passed from the root module."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used to launch the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the instance."
  type        = list(string)
}

variable "key_name" {
  description = "Optional key pair name for SSH access."
  type        = string
  default     = null
}
