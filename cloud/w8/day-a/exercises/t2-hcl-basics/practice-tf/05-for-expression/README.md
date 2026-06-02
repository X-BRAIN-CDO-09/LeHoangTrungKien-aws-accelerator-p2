# 05 - For Expression

## Mục tiêu

Luyện dùng `for` expression để tạo list/map mới.

## Đề bài

Trong `variables.tf`, khai báo:

- `project_name`: string.
- `environment`: string.
- `services`: list(string).

Trong `locals.tf`, tạo:

- `service_names`: list tên service theo format `<project>-<env>-<service>`.
- `service_map`: map service gốc sang service name đầy đủ.

Trong `outputs.tf`, output `service_names` và `service_map`.

## Yêu cầu

- Dùng `for` expression.
- Không viết thủ công từng service trong output.

