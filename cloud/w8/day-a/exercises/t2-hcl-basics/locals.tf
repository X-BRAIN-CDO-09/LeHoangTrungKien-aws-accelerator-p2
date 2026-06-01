locals {
  name_prefix = "${var.project}-${var.environment}"

  service_names = [
    for service in var.services : "${local.name_prefix}-${service}"
  ]

  common_tags = merge(
    var.default_tags,
    {
      owner       = var.owner
      environment = var.environment
      managed_by  = "terraform"
    }
  )
}
