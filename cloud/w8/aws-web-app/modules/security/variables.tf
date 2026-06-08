variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach the web server on HTTP."
  type        = string
}

variable "enable_ssh" {
  description = "Whether to allow SSH to the web server."
  type        = bool
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH when enable_ssh is true."
  type        = string
}

