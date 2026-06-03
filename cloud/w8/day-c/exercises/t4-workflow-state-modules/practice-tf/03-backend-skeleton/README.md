# 05 - Backend Skeleton

## Mục tiêu

Luyện tách file theo convention production: `provider.tf`, `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`.

## Đề bài

Trong `versions.tf`, khai báo `required_version`.

Trong `provider.tf`, viết skeleton cho:

- `terraform` block.
- `required_providers`.
- Optional backend block dạng comment hoặc placeholder.
- Provider block nếu muốn luyện AWS provider.

Trong `variables.tf`, khai báo input tối thiểu.

Trong `main.tf`, chỉ viết locals hoặc module giả nếu không muốn tạo AWS resource thật.

Trong `outputs.tf`, output giá trị kiểm tra.

## Yêu cầu

- Không dùng backend S3 thật nếu chưa có bucket state.
- Nếu chỉ luyện local, chạy `terraform init -backend=false`.
- Ghi vào reflection: provider nên để `provider.tf`, không nên nhét hết vào `main.tf` khi project lớn.

