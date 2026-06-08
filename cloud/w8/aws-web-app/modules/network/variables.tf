variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use."
  type        = number
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet outbound access."
  type        = bool
}

