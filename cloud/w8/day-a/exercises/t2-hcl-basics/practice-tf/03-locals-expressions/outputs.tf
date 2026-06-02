output "name_prefix" {
  description = "Generated name prefix built from project name and environment."
  value       = local.name_prefix
}

output "owner_slug" {
  description = "Owner name converted to lowercase kebab-case."
  value       = local.owner_slug
}

output "resource_base_name" {
  description = "Full base resource name built from the name prefix and owner slug."
  value       = local.resource_base_name
}
