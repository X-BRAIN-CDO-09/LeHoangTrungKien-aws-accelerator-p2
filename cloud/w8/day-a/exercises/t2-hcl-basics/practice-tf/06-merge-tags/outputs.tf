output "standard_tags" {
  description = "Merged standard tags built from default tags and project metadata."
  value       = local.standard_tags
}

output "cost_tags" {
  description = "Standard tags extended with a cost center tag."
  value       = local.cost_tags
}
