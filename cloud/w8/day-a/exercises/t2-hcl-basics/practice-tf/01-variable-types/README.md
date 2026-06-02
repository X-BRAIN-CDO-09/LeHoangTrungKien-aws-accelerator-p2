# 01 - Variable Types

## Mục tiêu

Luyện khai báo các kiểu dữ liệu cơ bản trong Terraform.

## Đề bài

Trong `variables.tf`, khai báo các biến sau:

- `project_name`: string.
- `environment`: string.
- `replica_count`: number.
- `enable_monitoring`: bool.
- `services`: list(string).
- `tags`: map(string).

Trong `outputs.tf`, output lại toàn bộ biến trên để kiểm tra Terraform đọc đúng kiểu dữ liệu.

## Yêu cầu

- Mỗi variable có `description`.
- Dùng `default` cho toàn bộ biến để có thể chạy `terraform plan` mà không cần `terraform.tfvars`.
- Chạy `terraform init -backend=false`, `terraform validate`, `terraform plan`.

