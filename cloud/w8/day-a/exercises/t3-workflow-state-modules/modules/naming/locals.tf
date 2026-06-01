locals {
  name_prefix = "${var.project_name}-${var.environment}"

  service_names = [
    for service in var.services : "${local.name_prefix}-${service}"
  ]

  standard_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "naming"
    }
  )
}

