locals {
  service_count = length(var.services)
  api_port      = var.service_ports["api"]
  tag_keys      = keys(var.default_tags)
}
