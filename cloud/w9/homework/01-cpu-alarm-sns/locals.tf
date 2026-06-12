locals {
  name_prefix = "${var.project_name}-cpu-alarm"

  monitored_instance_id = var.create_test_instance ? aws_instance.cpu_stress[0].id : var.instance_id

  common_tags = {
    Project   = var.project_name
    Week      = "W9"
    Homework  = "CPU Alarm SNS"
    StudentID = var.student_id
    ManagedBy = "Terraform"
  }
}
