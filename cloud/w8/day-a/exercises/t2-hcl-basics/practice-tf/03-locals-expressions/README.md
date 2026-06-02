# 03 - Locals Và Expressions

## Mục tiêu

Luyện tạo giá trị trung gian bằng `locals`.

## Đề bài

Trong `variables.tf`, khai báo:

- `project_name`
- `environment`
- `owner`

Trong `locals.tf`, tạo:

- `name_prefix`: ghép `project_name` và `environment`.
- `owner_slug`: biến `owner` thành dạng dùng được trong tên tài nguyên.
- `resource_base_name`: ghép `name_prefix` và `owner_slug`.

Trong `outputs.tf`, output các local trên.

## Yêu cầu

- Không copy nguyên variable sang local nếu không cần tính toán.
- Local phải là giá trị dẫn xuất từ variable.

