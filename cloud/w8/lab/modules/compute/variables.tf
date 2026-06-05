variable "name_prefix" {
  description = "Prefix used for compute resource names."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Kubernetes host."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the EC2 instance."
  type        = list(string)
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH access."
  type        = string
  default     = null
}

variable "app_image" {
  description = "Public Docker image deployed to Kubernetes."
  type        = string
}

variable "app_node_port" {
  description = "NodePort exposed on the EC2 host."
  type        = number
}

variable "user_data_template" {
  description = "Path to the EC2 user_data template."
  type        = string
}
