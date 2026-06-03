variable "project_name" {
  description = "Project name used for VPC naming."
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_cidr_subnet" {
  type = list(string)
}

variable "sg_name" {
  type = string
}
