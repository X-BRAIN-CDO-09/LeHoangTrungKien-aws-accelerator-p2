locals {
  name_prefix = "${var.project_name}-${var.environment}"

  service_names = [
    for service in var.services : "${local.name_prefix}-${service}"
  ]

  service_map = {
    for service in var.services : service => "${local.name_prefix}-${service}"
  }

  owner_metadata = {
    owner       = var.owner
    environment = var.environment
    project     = var.project_name
  }

  demo_secret = var.demo_secret
}
