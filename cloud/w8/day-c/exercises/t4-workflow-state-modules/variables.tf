variable "project_name" {
  description = "Tên dự án dùng để tạo tiền tố tài nguyên"
  type        = string
}

variable "environment" {
  description = "Tên môi trường triển khai"
  type        = string
}

variable "services" {
  description = "Danh sách service cần tạo tên chuẩn hóa"
  type        = list(string)
}

variable "tags" {
  description = "Bộ tag mô phỏng metadata của môi trường"
  type        = map(string)
}

