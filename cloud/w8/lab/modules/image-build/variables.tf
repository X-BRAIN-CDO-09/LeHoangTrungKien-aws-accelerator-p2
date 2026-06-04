variable "aws_region" {
  description = "AWS region used for ECR login."
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry hostname."
  type        = string
}

variable "image_uri" {
  description = "Full image URI to build and push."
  type        = string
}

variable "app_dir" {
  description = "Local path to the demo app Docker build context."
  type        = string
}
