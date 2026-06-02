variable "project_name" {
  description = "Project name that must be provided through terraform.tfvars because it is project-specific."
  type        = string
}

variable "environment" {
  description = "Deployment environment name. Defaults to dev for this practice exercise."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Target AWS region that must be provided through terraform.tfvars because it can differ per environment."
  type        = string
}

variable "backend_port" {
  description = "Backend service port used to practice default values."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Backend health check path used to practice default values."
  type        = string
  default     = "/health"
}
