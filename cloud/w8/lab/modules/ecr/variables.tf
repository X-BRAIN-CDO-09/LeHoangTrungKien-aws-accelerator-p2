variable "name_prefix" {
  description = "Prefix used for ECR resource names."
  type        = string
}

variable "suffix" {
  description = "Stable suffix used to make the ECR repository name unique."
  type        = string
}
