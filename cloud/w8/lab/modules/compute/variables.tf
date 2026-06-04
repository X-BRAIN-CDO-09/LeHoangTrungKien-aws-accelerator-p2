variable "name_prefix" {
  description = "Prefix used for compute resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by EC2 user_data."
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

variable "ecr_registry" {
  description = "ECR registry hostname."
  type        = string
}

variable "app_image" {
  description = "ECR image URI deployed to Kubernetes."
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

variable "image_build_complete" {
  description = "Dependency handle that changes when the image build completes."
  type        = string
}
