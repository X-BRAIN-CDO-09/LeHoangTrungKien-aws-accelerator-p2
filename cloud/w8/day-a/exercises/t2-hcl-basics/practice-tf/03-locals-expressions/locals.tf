locals {
  name_prefix = "${var.project_name}-${var.environment}"

  owner_slug = lower(replace(trimspace(var.owner), " ", "-"))

  resource_base_name = "${local.name_prefix}-${local.owner_slug}"
}
