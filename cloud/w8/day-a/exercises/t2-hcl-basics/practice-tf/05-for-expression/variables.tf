variable "project_name" {
  description = "Project name used as the first part of generated service names."
  type        = string
  default     = "aws-accelerator-p2"
}

variable "environment" {
  description = "Environment name used as the second part of generated service names."
  type        = string
  default     = "dev"
}

variable "services" {
  description = "List of service names used to practice for expressions."
  type        = list(string)
  default     = ["api", "worker", "web"]
}
