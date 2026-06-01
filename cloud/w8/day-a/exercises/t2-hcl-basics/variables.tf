variable "project" {
  description = "Short project name used for naming examples."
  type        = string
  default     = "aws-accelerator-p2"
}

variable "environment" {
  description = "Target environment name."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Repository owner or learner name."
  type        = string
  default     = "LeHoangTrungKien"
}

variable "services" {
  description = "Example service names used to practice list expressions."
  type        = list(string)
  default     = ["api", "worker", "web"]
}

variable "default_tags" {
  description = "Example tag map used to practice map values."
  type        = map(string)
  default = {
    phase = "2"
    week  = "8"
    day   = "1"
  }
}
