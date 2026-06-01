# 02 - Cú Pháp HCL Cơ Bản

## Mục Tiêu

Sau phần này, mình cần đọc được các file Terraform cơ bản:

- `variables.tf`
- `locals.tf`
- `outputs.tf`
- `main.tf`

Mình cũng cần hiểu `default`, `var`, `local`, `for`, `merge`, `map`, `list`, `object`.

## 1. HCL Là Gì?

Terraform dùng HCL, viết tắt của HashiCorp Configuration Language.

HCL là ngôn ngữ cấu hình, không phải ngôn ngữ lập trình theo kiểu Python hay C#. Mình dùng HCL để mô tả trạng thái mong muốn.

Ví dụ:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = "my-demo-bucket"
}
```

Ý nghĩa: tôi muốn có một S3 bucket tên `my-demo-bucket`.

## 2. Block Và Argument

HCL được tạo từ block và argument.

```hcl
block_type "label" {
  argument = value
}
```

Ví dụ:

```hcl
variable "environment" {
  description = "Tên môi trường"
  type        = string
  default     = "dev"
}
```

Giải thích từng dòng:

```hcl
variable "environment" {
```

Khai báo một block loại `variable`, tên biến là `environment`.

```hcl
description = "Tên môi trường"
```

Mô tả biến này dùng để làm gì.

```hcl
type = string
```

Biến này chỉ nhận giá trị dạng chuỗi.

```hcl
default = "dev"
```

Nếu không truyền giá trị, Terraform dùng `"dev"`.

## 3. Kiểu Dữ Liệu Cơ Bản

### String

```hcl
environment = "dev"
```

Chuỗi phải nằm trong dấu nháy kép.

### Number

```hcl
desired_count = 2
```

Dùng cho số lượng, dung lượng, CPU, memory.

### Boolean

```hcl
multi_az = false
```

Chỉ có `true` hoặc `false`.

### List

```hcl
services = ["api", "worker", "web"]
```

List là danh sách có thứ tự.

### Map

```hcl
tags = {
  Owner       = "LeHoangTrungKien"
  Environment = "dev"
}
```

Map là tập key-value.

### Object

```hcl
subnet = {
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  type              = "app"
}
```

Object có nhiều field được định nghĩa rõ.

## 4. `variable` Và `var`

`variable` dùng để khai báo input.

```hcl
variable "project_name" {
  description = "Tên dự án"
  type        = string
}
```

Sau khi khai báo, dùng giá trị bằng:

```hcl
var.project_name
```

Ví dụ:

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
```

Nếu:

```hcl
project_name = "budget-bot"
environment  = "dev"
```

thì:

```text
local.name_prefix = "budget-bot-dev"
```

## 5. `default` Là Gì?

`default` là giá trị mặc định nếu không truyền input.

```hcl
variable "environment" {
  description = "Tên môi trường"
  type        = string
  default     = "dev"
}
```

Nếu không có `default`, biến đó bắt buộc phải được truyền.

Ví dụ:

```hcl
variable "aws_region" {
  description = "Vùng AWS"
  type        = string
}
```

Nếu không truyền `aws_region`, Terraform sẽ hỏi hoặc báo lỗi trong CI/CD.

Quy tắc tốt:

- Giá trị quan trọng theo môi trường thì không nên có `default`.
- Giá trị optional an toàn thì có thể có `default`.

Ví dụ nên có default:

```hcl
variable "public_subnets" {
  description = "Bản đồ subnet public"
  type        = map(any)
  default     = {}
}
```

`default = {}` nghĩa là nếu không cần public subnet thì dùng map rỗng.

## 6. `terraform.tfvars`

`variables.tf` khai báo biến. `terraform.tfvars` truyền giá trị thật.

`variables.tf`:

```hcl
variable "project_name" {
  description = "Tên dự án"
  type        = string
}
```

`terraform.tfvars`:

```hcl
project_name = "budget-bot"
```

`main.tf` hoặc `locals.tf`:

```hcl
local.name_prefix = var.project_name
```

Luồng:

```text
variables.tf khai báo project_name
terraform.tfvars gán project_name = "budget-bot"
code Terraform dùng var.project_name
```

## 7. `locals` Và `local`

`locals` dùng để tạo giá trị tính toán bên trong module.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
```

Dùng bằng:

```hcl
local.name_prefix
```

Khác nhau:

- `var.project_name`: input từ bên ngoài.
- `local.name_prefix`: giá trị được tính bên trong.

## 8. `output`

Output trả giá trị ra ngoài.

```hcl
output "service_names" {
  description = "Danh sách tên service"
  value       = local.service_names
}
```

Root output giúp người chạy Terraform xem kết quả.

Module output giúp module cha dùng kết quả của module con.

## 9. For Expression

Ví dụ trong exercise T2:

```hcl
service_names = [
  for service in var.services : "${local.name_prefix}-${service}"
]
```

Nếu:

```hcl
services = ["api", "worker", "web"]
name_prefix = "budget-bot-dev"
```

thì kết quả:

```hcl
[
  "budget-bot-dev-api",
  "budget-bot-dev-worker",
  "budget-bot-dev-web"
]
```

Giải thích:

- `for service in var.services`: duyệt từng service.
- `service`: biến tạm.
- `"${local.name_prefix}-${service}"`: tạo chuỗi mới.
- Kết quả là list mới.

## 10. `merge`

`merge` dùng để gộp map.

```hcl
common_tags = merge(
  var.default_tags,
  {
    owner       = var.owner
    environment = var.environment
    managed_by  = "terraform"
  }
)
```

Nếu hai map có cùng key, map phía sau ghi đè map phía trước.

Ứng dụng:

- Gộp tag mặc định với tag riêng.
- Bổ sung metadata như `ManagedBy = "Terraform"`.

## 11. Đọc Exercise T2 Theo Thứ Tự

Đọc:

```text
exercises/t2-hcl-basics/variables.tf
exercises/t2-hcl-basics/locals.tf
exercises/t2-hcl-basics/outputs.tf
```

Chạy:

```bash
cd cloud/w8/day-a/exercises/t2-hcl-basics
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan
```

Kết quả plan chỉ có output, không tạo AWS resource.

## 12. Checklist Sau Khi Đọc

Tự trả lời:

1. `variable` khác `var` ở điểm nào?
2. `default` dùng để làm gì?
3. `local` khác `variable` ở điểm nào?
4. `for` expression tạo list mới như thế nào?
5. `merge` dùng để giải quyết vấn đề gì?

