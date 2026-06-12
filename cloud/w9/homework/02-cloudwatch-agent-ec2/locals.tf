locals {
  name_prefix = var.project_name

  common_tags = {
    Project   = var.project_name
    Week      = "W9"
    Homework  = "CloudWatch Agent EC2"
    StudentID = var.student_id
    ManagedBy = "Terraform"
  }
}

