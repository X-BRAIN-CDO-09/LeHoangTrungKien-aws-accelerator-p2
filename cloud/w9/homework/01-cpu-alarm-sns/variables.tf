variable "aws_region" {
  description = "AWS region where the EC2 instance and monitoring resources live."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix for homework resources."
  type        = string
  default     = "w9-monitoring-homework"
}

variable "student_id" {
  description = "Student ID used in tags."
  type        = string
  default     = "XB-DN26-045"
}

variable "notification_email" {
  description = "Email address that receives SNS alarm notifications."
  type        = string
}

variable "instance_id" {
  description = "Existing EC2 instance ID to monitor. Leave null when create_test_instance is true."
  type        = string
  default     = null
}

variable "create_test_instance" {
  description = "Whether to create a temporary EC2 instance that burns CPU using user data."
  type        = bool
  default     = false
}

variable "test_instance_type" {
  description = "Instance type for the optional CPU stress test EC2."
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "Optional VPC ID for the CPU stress test EC2. If null, Terraform uses the default VPC."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Optional subnet ID for the CPU stress test EC2. If null, Terraform uses the first subnet in the selected VPC."
  type        = string
  default     = null
}

variable "cpu_threshold" {
  description = "CPU percentage threshold that triggers the alarm."
  type        = number
  default     = 80
}

variable "evaluation_periods" {
  description = "Number of consecutive periods before the alarm fires."
  type        = number
  default     = 5
}

variable "period_seconds" {
  description = "CloudWatch alarm period in seconds."
  type        = number
  default     = 60
}
