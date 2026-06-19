data "aws_caller_identity" "current" {}

locals {
  bucket_suffix = var.bucket_name_suffix != "" ? var.bucket_name_suffix : data.aws_caller_identity.current.account_id
  bucket_name   = "${var.project_name}-${local.bucket_suffix}"

  sample_files = fileset("${path.module}/${var.sample_data_dir}", "**/*")

  common_tags = {
    Project   = var.project_name
    StudentId = var.student_id
    Week      = "W10"
    Homework  = "MacieS3SensitiveDataAlert"
    ManagedBy = "Terraform"
  }
}
