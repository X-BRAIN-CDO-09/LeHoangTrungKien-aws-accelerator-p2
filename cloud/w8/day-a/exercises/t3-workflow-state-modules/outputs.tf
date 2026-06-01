output "name_prefix" {
  description = "Tiền tố tên tài nguyên trả về từ module naming"
  value       = module.naming.name_prefix
}

output "service_names" {
  description = "Danh sách tên service chuẩn hóa trả về từ module naming"
  value       = module.naming.service_names
}

output "standard_tags" {
  description = "Bộ tag chuẩn hóa trả về từ module naming"
  value       = module.naming.standard_tags
}

