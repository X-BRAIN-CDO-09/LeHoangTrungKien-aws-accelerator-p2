variable "aws_region" {
  description = "AWS region used for the EC2 CloudWatch Agent lab."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix for homework resources."
  type        = string
  default     = "w9-cloudwatch-agent"
}

variable "student_id" {
  description = "Student ID used in tags."
  type        = string
  default     = "XB-DN26-045"
}

variable "instance_type" {
  description = "EC2 instance type for the CloudWatch Agent lab."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 8
}

variable "vpc_id" {
  description = "Optional VPC ID. If null, Terraform uses the default VPC."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Optional subnet ID. If null, Terraform uses the first subnet in the selected VPC."
  type        = string
  default     = null
}

