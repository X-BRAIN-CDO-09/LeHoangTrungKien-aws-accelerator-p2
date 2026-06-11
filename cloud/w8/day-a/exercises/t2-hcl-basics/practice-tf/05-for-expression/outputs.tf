output "service_names" {
  description = "List of full service names generated from project, environment, and service names."
  value       = local.service_names
}

output "service_map" {
  description = "Map from original service name to full generated service name."
  value       = local.service_map
}