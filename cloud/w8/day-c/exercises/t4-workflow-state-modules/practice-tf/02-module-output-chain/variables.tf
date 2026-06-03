variable "project_name" {
  description = "Project name used to build tag and name values."
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