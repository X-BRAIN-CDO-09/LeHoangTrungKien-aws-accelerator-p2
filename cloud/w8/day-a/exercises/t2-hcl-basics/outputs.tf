output "name_prefix" {
  description = "Generated name prefix from project and environment."
  value       = local.name_prefix
}

output "service_names" {
  description = "Generated service names from a list expression."
  value       = local.service_names
}

output "common_tags" {
  description = "Merged tags from defaults and local metadata."
  value       = local.common_tags
}
