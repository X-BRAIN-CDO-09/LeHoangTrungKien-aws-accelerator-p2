# 02 - Default Values Và tfvars Override

## Mục tiêu

Hiểu biến nào nên có `default`, biến nào nên truyền qua `terraform.tfvars`.

## Đề bài

Trong `variables.tf`, khai báo:

- `project_name`: string, không có default.
- `environment`: string, default là `dev`.
- `aws_region`: string, không có default.
- `backend_port`: number, default là `8080`.
- `health_check_path`: string, default là `/health`.

Trong `terraform.tfvars`, truyền giá trị cho các biến bắt buộc.

Trong `outputs.tf`, output các giá trị cuối cùng Terraform đang dùng.

## Yêu cầu
- Chạy `terraform plan` hai lần: một lần thiếu tfvars để thấy lỗi, một lần đủ tfvars để thấy pass.
