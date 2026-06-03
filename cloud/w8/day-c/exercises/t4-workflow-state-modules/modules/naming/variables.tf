variable "project_name" {
  description = "Tên dự án nhận từ root module"
  type        = string
}

variable "environment" {
  description = "Tên môi trường nhận từ root module"
  type        = string
}

variable "services" {
  description = "Danh sách service nhận từ root module"
  type        = list(string)
}

variable "tags" {
  description = "Bộ tag nhận từ root module"
  type        = map(string)
}

