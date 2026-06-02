variable "project_name" {
  description = "Project name used to build derived naming values."
  type        = string
  default     = "KienXBrain"
}

variable "environment" {
  description = "Target environment name used in generated resource names."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner name that will be converted into a slug."
  type        = string
  default     = "Le Hoang Trung Kien"
}
