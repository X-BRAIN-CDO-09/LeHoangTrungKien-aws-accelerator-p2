data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${data.aws_caller_identity.current.account_id}"

  cloudtrail_bucket_name = lower("${local.name_prefix}-${var.aws_region}")

  cloudwatch_log_group_name = "/aws/cloudtrail/${var.project_name}"

  common_tags = {
    Project   = var.project_name
    Week      = "W9"
    Homework  = "Root Account Login Alert"
    StudentID = var.student_id
    ManagedBy = "Terraform"
  }
}
