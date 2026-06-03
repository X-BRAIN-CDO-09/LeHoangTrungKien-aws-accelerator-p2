# 06 - Provider, Resource, Data Source, Meta-arguments

## Mục tiêu

Luyện nhận diện và viết skeleton cho các building blocks chính của Terraform:

- Provider
- Resource
- Data source
- Variables
- Locals
- Outputs
- Modules
- Meta-arguments

## Đề bài

Trong `versions.tf`, khai báo:

- `required_version`.
- `required_providers` nếu muốn luyện provider AWS.

Trong `provider.tf`, viết provider skeleton. Nếu chưa muốn kết nối AWS thật, có thể chỉ viết comment hoặc giữ file trống.

Trong `variables.tf`, khai báo:

- `project_name`
- `environment`
- `enable_example`
- Một map hoặc list để luyện `for_each`.

Trong `main.tf`, viết skeleton cho:

- Một `data` block mẫu, ví dụ đọc account identity nếu dùng AWS.
- Một `resource` block mẫu nếu muốn luyện provider thật.
- Một block dùng `count`.
- Một block dùng `for_each`.

Trong `locals.tf`, tạo giá trị trung gian như `name_prefix` hoặc `standard_tags`.

Trong `outputs.tf`, output ít nhất:

- Một giá trị từ variable.
- Một giá trị từ local.
- Một giá trị từ data/resource nếu có viết.

## Yêu cầu

- Không tạo AWS resource thật nếu chưa chắc provider/credentials đã đúng.
- Nếu chỉ luyện syntax, có thể giữ resource/data dưới dạng comment trong `main.tf`.

