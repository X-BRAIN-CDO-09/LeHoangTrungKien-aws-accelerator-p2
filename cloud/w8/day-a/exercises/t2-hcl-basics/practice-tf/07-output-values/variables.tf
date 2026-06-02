variable "project_name" {
  description = "Project name used to build output values."
  type        = string
  default     = "aws-accelerator-p2"
}

variable "environment" {
  description = "Environment name used to build output values."
  type        = string
  default     = "dev"
}

variable "services" {
  description = "List of services used to build list outputs."
  type        = list(string)
  default     = ["api", "worker", "web"]
}

variable "owner" {
  description = "Owner name used to build map outputs."
  type        = string
  default     = "LeHoangTrungKien"
}

variable "demo_secret" {
  description = "Demo sensitive value used to practice sensitive outputs."
  type        = string
  default     = "do-not-use-real-secrets"
  sensitive   = true
}
