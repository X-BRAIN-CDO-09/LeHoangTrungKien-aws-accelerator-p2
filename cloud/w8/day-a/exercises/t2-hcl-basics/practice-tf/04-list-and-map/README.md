# 04 - List Và Map

## Mục tiêu

Luyện đọc và biến đổi list/map trong Terraform.

## Đề bài

Trong `variables.tf`, khai báo:

- `services`: list(string).
- `service_ports`: map(number).
- `default_tags`: map(string).

Trong `locals.tf`, tạo:

- `service_count`: số lượng service.
- `api_port`: port của service `api`.
- `tag_keys`: danh sách key trong `default_tags`.

Trong `outputs.tf`, output các giá trị trên.

## Yêu cầu

- Dùng đúng type cho list và map.
- Không hardcode kết quả nếu có thể lấy từ variable.

