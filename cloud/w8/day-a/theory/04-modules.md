# 04 - Modules Và Luồng Dữ Liệu Terraform

## Mục Tiêu

Sau phần này, mình cần hiểu:

- Root module là gì.
- Child module là gì.
- `variables.tf`, `terraform.tfvars`, `main.tf`, `outputs.tf` liên kết như thế nào.
- Output của module này truyền sang module khác ra sao.
- Terraform tự hiểu dependency bằng cách nào.

## 1. Module Là Gì?

Module là một folder chứa Terraform code.

Một module thường có:

```text
main.tf
variables.tf
outputs.tf
```

Trong Terraform, mọi folder chạy Terraform đều là module.

## 2. Root Module

Root module là folder nơi mình chạy lệnh:

```bash
terraform init
terraform plan
terraform apply
```

Trong `Terraform_Hackathon`, root module chính là:

```text
environments/budget_bot/
```

Nó có:

```text
provider.tf
variables.tf
terraform.tfvars
main.tf
outputs.tf
```

## 3. Child Module

Child module là module được root module gọi.

Ví dụ:

```text
modules/s3/
modules/vpc/
modules/lambda/
modules/api_gateway/
```

Root gọi child module bằng block `module`.

```hcl
module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  buckets = {
    "frontend" = {}
    "csv-data" = {}
  }
}
```

Giải thích:

```hcl
module "s3"
```

Tạo một instance module tên `s3`.

```hcl
source = "../../modules/s3"
```

Chỉ đường dẫn tới child module.

```hcl
project_name = var.project_name
```

Truyền input `project_name` vào child module.

```hcl
buckets = { ... }
```

Truyền input `buckets` vào child module.

## 4. Child Module Nhận Input Như Thế Nào?

Trong `modules/s3/variables.tf`, child module phải khai báo input:

```hcl
variable "project_name" {
  description = "Tên dự án"
  type        = string
}

variable "buckets" {
  description = "Danh sách bucket cần tạo"
  type        = map(object({}))
}
```

Nếu root truyền `project_name`, child module phải có `variable "project_name"`.

Nếu không, Terraform báo lỗi.

## 5. Module Output

Child module trả dữ liệu ra ngoài bằng `output`.

Ví dụ:

```hcl
output "bucket_ids" {
  description = "Tên các bucket đã tạo"
  value       = { for k, b in aws_s3_bucket.this : k => b.id }
}
```

Root module dùng output bằng:

```hcl
module.s3.bucket_ids
module.s3.bucket_ids["csv-data"]
```

Đây là cầu nối giữa module con và module cha.

## 6. Luồng Dữ Liệu Đầy Đủ

Luồng dữ liệu đầy đủ bắt đầu từ `terraform.tfvars`, nơi chứa giá trị thật của environment. Các giá trị này khớp với khai báo trong root `variables.tf`, sau đó được dùng trong code thông qua `var.<name>`. Từ `main.tf`, root module truyền giá trị vào child module. Child module nhận input qua `variables.tf`, tạo resource trong `main.tf`, rồi trả kết quả qua `outputs.tf`. Root module đọc kết quả đó bằng `module.<name>.<output>` và có thể truyền tiếp sang module khác hoặc xuất ra root `outputs.tf`.

Ví dụ S3 sang Lambda: `terraform.tfvars` truyền `project_name = "budget-bot"` vào root module. Root `main.tf` dùng giá trị này khi gọi `module "s3"`. Module S3 tạo bucket `csv-data` và trả về `bucket_ids`. Root module đọc `module.s3.bucket_ids["csv-data"]`, đưa giá trị đó vào `local.dynamic_lambdas`, rồi truyền cấu hình đã xử lý sang `module "lambda"`. Kết quả là Lambda được tạo với environment variable `STORAGE_BUCKET` trỏ tới bucket thật.

## 7. `locals` Khi Nối Module

Trong `Terraform_Hackathon`, root module có pattern tốt:

```hcl
locals {
  dynamic_lambdas = {
    for k, v in var.lambdas : k => merge(v, {
      environment_variables = merge(v.environment_variables, {
        "STORAGE_BUCKET" = module.s3.bucket_ids["csv-data"]
      })
    })
  }
}
```

Ý nghĩa:

- `var.lambdas`: cấu hình Lambda ban đầu từ `terraform.tfvars`.
- `module.s3.bucket_ids["csv-data"]`: bucket thật do module S3 tạo.
- `local.dynamic_lambdas`: cấu hình Lambda đã được bổ sung env var.
- `module.lambda`: nhận cấu hình đã xử lý.

Đây là cách module giao tiếp với nhau qua output, không hardcode tên resource.

## 8. Terraform Dependency Graph

Terraform không chạy file theo thứ tự tên file.

Nó đọc tất cả `.tf`, sau đó dựng graph dependency.

Ví dụ:

```hcl
module "lambda_sg" {
  vpc_id = module.vpc.vpc_id
}
```

Terraform thấy `module.lambda_sg` phụ thuộc vào `module.vpc`, vì security group cần giá trị `module.vpc.vpc_id`.

Ví dụ khác:

```hcl
module "lambda" {
  vpc_subnet_ids         = module.vpc.app_subnet_ids
  vpc_security_group_ids = [module.lambda_sg.security_group_id]
}
```

Terraform hiểu rằng Lambda phụ thuộc vào cả VPC và security group, vì `module "lambda"` đang dùng output từ hai module đó.

Chỉ dùng `depends_on` khi dependency thật sự tồn tại nhưng không thể hiện qua input/output.

## 9. Exercise T3

Folder:

```text
exercises/t3-workflow-state-modules/
```

Trong mini project này, `terraform.tfvars` cung cấp dữ liệu cho root `variables.tf`. Root `main.tf` gọi `modules/naming`, child module tính toán trong `locals.tf`, trả kết quả ở `outputs.tf`, rồi root module xuất lại các giá trị đó trong root `outputs.tf`.

Chạy:

```bash
cd cloud/w8/day-a/exercises/t3-workflow-state-modules
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan
```

Kỳ vọng output:

```text
name_prefix   = "budget-bot-dev"
service_names = ["budget-bot-dev-api", "budget-bot-dev-worker", "budget-bot-dev-web"]
```

## 10. Checklist Sau Khi Đọc

Tự trả lời:

1. Root module khác child module ở điểm nào?
2. `source` trong block module dùng để làm gì?
3. Vì sao child module cần `variables.tf`?
4. Vì sao module cần `outputs.tf`?
5. Terraform biết module nào chạy trước bằng cách nào?
