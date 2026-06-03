# 04 - Module Output Chain

## Mục tiêu

Luyện truyền output của module này sang input của module khác.

## Đề bài

Tạo hai child module:

- `modules/naming`: nhận project/environment, trả `name_prefix`.
- `modules/tags`: nhận `name_prefix` và tags gốc, trả `standard_tags`.

Trong root `main.tf`:

- Gọi `module "naming"` trước.
- Gọi `module "tags"` và truyền `module.naming.name_prefix` vào.

Trong root `outputs.tf`, output cả `name_prefix` và `standard_tags`.

## Yêu cầu

- Không hardcode `name_prefix` trong module tags.
- Dùng output từ module naming làm input cho module tags.

## Skeleton Thêm Để Tự Luyện

Trong `modules/` có thêm hai module rỗng là `VPC` và `EC2`. Chúng chưa được gọi từ root `main.tf`; mục đích là để bạn tự luyện bước kế tiếp: tạo output từ module VPC rồi truyền sang module EC2.
