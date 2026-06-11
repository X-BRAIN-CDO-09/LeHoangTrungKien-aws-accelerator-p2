output "name_prefix" {
  description = "String output containing the generated name prefix."
  value       = local.name_prefix
}

output "service_names" {
  description = "List output containing full service names generated from project, environment, and service names."
  value       = local.service_names
}

output "service_map" {
  description = "Map output from original service name to full generated service name."
  value       = local.service_map
}

output "owner_metadata" {
  description = "Map output containing owner, project, and environment metadata."
  value       = local.owner_metadata
}

output "demo_secret" {
  description = "Sensitive demo output used to practice hidden output values."
  value       = local.demo_secret
  sensitive   = true
}
