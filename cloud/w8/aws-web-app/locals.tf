data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  asset_bucket_name = lower(replace(
    "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-assets",
    "_",
    "-"
  ))

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Lab         = "cloud-w8-aws-web-app"
  }
}
