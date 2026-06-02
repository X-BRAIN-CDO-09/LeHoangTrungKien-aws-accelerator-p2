variable "project_name" {
  description = "Project name used to build standardized tags."
  type        = string
  default     = "aws-accelerator-p2"
}

variable "environment" {
  description = "Environment name used to build standardized tags."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner name used to build standardized tags."
  type        = string
  default     = "LeHoangTrungKien"
}

variable "default_tags" {
  description = "Base tags that will be merged with standardized metadata tags."
  type        = map(string)
  default = {
    Phase       = "2"
    Week        = "8"
    Environment = "override-me"
  }
}
