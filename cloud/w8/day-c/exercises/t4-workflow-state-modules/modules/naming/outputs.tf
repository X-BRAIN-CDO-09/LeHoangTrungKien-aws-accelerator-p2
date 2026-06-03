output "name_prefix" {
  description = "Tiền tố tên tài nguyên đã được tính trong child module"
  value       = local.name_prefix
}

output "service_names" {
  description = "Danh sách tên service đã được chuẩn hóa trong child module"
  value       = local.service_names
}

output "standard_tags" {
  description = "Bộ tag đã được bổ sung metadata trong child module"
  value       = local.standard_tags
}

