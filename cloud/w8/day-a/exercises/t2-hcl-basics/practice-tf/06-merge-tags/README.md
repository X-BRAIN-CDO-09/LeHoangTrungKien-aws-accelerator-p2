# 06 - Merge Tags

## Mục tiêu

Luyện dùng `merge` để chuẩn hóa tags.

## Đề bài

Trong `variables.tf`, khai báo:

- `project_name`: string.
- `environment`: string.
- `owner`: string.
- `default_tags`: map(string).

Trong `locals.tf`, tạo:

- `standard_tags`: gộp `default_tags` với `Project`, `Environment`, `Owner`, `ManagedBy`.
- `cost_tags`: gộp `standard_tags` với `CostCenter`.

Trong `outputs.tf`, output `standard_tags` và `cost_tags`.

## Yêu cầu

- Dùng `merge`.
- Thử cố tình truyền trùng key để quan sát map phía sau ghi đè map phía trước.

