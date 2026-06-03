# 06 - Terraform Building Blocks: Provider, Resource, Data Source, Meta-arguments

## Mục Tiêu

Sau phần này, mình cần phân biệt được các khối Terraform thường gặp:

- Configure providers
- Resources
- Data sources
- Variables
- Locals
- Outputs
- Modules
- Meta-arguments

Các phần `Variables`, `Locals`, `Outputs` đã học ở T2. Phần `Modules` đã học ở T3. File này gom lại toàn bộ để khi đọc repo thật, mình biết block nào dùng để làm gì.

## 1. Configure Providers

Provider là plugin giúp Terraform nói chuyện với một nền tảng như AWS, Kubernetes, GitHub hoặc OpenSearch.

Ví dụ AWS provider:

```hcl
provider "aws" {
  region = var.aws_region
}
```

Trong project nhỏ, provider có thể nằm trong `main.tf` và Terraform vẫn chạy. Nhưng best practice là tách ra `provider.tf`, vì provider/backend là cấu hình nền của root module, không phải resource chính.

Convention nên dùng:

```text
provider.tf   cấu hình provider và backend
versions.tf   required_version và required_providers
variables.tf  input
main.tf       resource hoặc module call
outputs.tf    output
```

Ví dụ trong `Terraform_Hackathon/environments/budget_bot/provider.tf`, provider AWS còn có `default_tags` để tự gắn tag mặc định cho resource AWS.

## 2. Resources

Resource là tài nguyên thật mà Terraform tạo, sửa hoặc xóa.

Ví dụ:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = "example-bucket"
}
```

Giải thích:

- `resource`: khai báo tài nguyên được Terraform quản lý.
- `aws_s3_bucket`: loại resource trong AWS provider.
- `this`: tên nội bộ trong Terraform.
- `bucket`: argument của resource.

Resource thường nằm trong `main.tf` của module.

Ví dụ trong module ALB của `terraform_xbrain`, các resource chính là `aws_lb`, `aws_lb_target_group`, `aws_lb_listener`.

## 3. Data Sources

Data source dùng để đọc thông tin đã tồn tại, không tạo resource mới.

Ví dụ:

```hcl
data "aws_caller_identity" "current" {}
```

Data source này hỏi AWS rằng account hiện tại là account nào. Sau đó có thể dùng:

```hcl
data.aws_caller_identity.current.account_id
```

Khi nào dùng data source:

- Cần đọc account id hiện tại.
- Cần tìm AMI có sẵn.
- Cần đọc VPC/subnet/security group đã tồn tại.
- Cần lấy thông tin từ AWS để truyền vào resource/module khác.

Phân biệt nhanh:

- `resource`: Terraform quản lý vòng đời tài nguyên.
- `data`: Terraform chỉ đọc thông tin.

## 4. Variables

Variable là input của root module hoặc child module.

```hcl
variable "project_name" {
  description = "Project name."
  type        = string
}
```

Root module nhận giá trị từ `terraform.tfvars`, default, environment variable `TF_VAR_*`, hoặc nhập tay khi chạy plan/apply.

Child module nhận giá trị từ root `main.tf`:

```hcl
module "alb" {
  source = "../module/ALB"

  project_name = var.project_name
}
```

## 5. Locals

Local là giá trị trung gian được tính bên trong module.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
```

Dùng local khi cần:

- Ghép tên tài nguyên.
- Chuẩn hóa tags.
- Dùng `for` expression.
- Dùng `merge`.
- Tránh viết lại một biểu thức dài nhiều lần.

Không dùng local để copy lại tất cả variable. Local chỉ nên chứa giá trị cần tính toán hoặc cần đặt tên cho dễ đọc.

## 6. Outputs

Output là giá trị module trả ra.

```hcl
output "alb_dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.backend.dns_name
}
```

Root output giúp người vận hành xem kết quả sau khi apply. Child module output giúp root module hoặc module khác dùng lại giá trị.

Ví dụ:

```hcl
module "ecs_backend" {
  target_group_arn = module.alb.target_group_arn
}
```

Ở đây `module.alb.target_group_arn` là output từ module ALB được truyền sang module ECS.

## 7. Modules

Module là một folder Terraform có thể tái sử dụng.

Root module gọi child module:

```hcl
module "networking" {
  source = "../module/Networking"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}
```

Child module cần khai báo input trong `variables.tf`, tạo resource trong `main.tf`, và trả giá trị cần thiết qua `outputs.tf`.

Best practice khi viết module:

- Interface rõ ràng.
- Input có type cụ thể.
- Output chỉ trả giá trị cần dùng.
- Không expose quá nhiều biến chỉ để "linh hoạt".

## 8. Meta-arguments

Meta-arguments là các argument đặc biệt Terraform hỗ trợ cho resource/module block. Chúng không thuộc riêng AWS hay provider nào.

Các meta-arguments thường gặp:

- `count`
- `for_each`
- `depends_on`
- `provider`
- `lifecycle`

### `count`

Dùng để tạo 0, 1 hoặc nhiều instance theo số lượng.

```hcl
module "database_mysql" {
  count  = var.enable_rds ? 1 : 0
  source = "../module/Database_MySQL"
}
```

Nếu `enable_rds = true`, module được tạo 1 lần. Nếu `false`, module không được tạo.

### `for_each`

Dùng để tạo nhiều instance theo map hoặc set.

```hcl
resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket = each.key
}
```

`for_each` phù hợp khi mỗi item có key rõ ràng như tên bucket, tên route, tên Lambda.

### `depends_on`

Dùng khi Terraform không tự nhìn ra dependency qua reference.

```hcl
resource "example_resource" "this" {
  depends_on = [module.networking]
}
```

Không nên lạm dụng `depends_on`. Nếu resource đã dùng output của resource/module khác, Terraform thường tự hiểu dependency.

### `lifecycle`

Dùng để điều chỉnh cách Terraform xử lý vòng đời resource.

```hcl
resource "example_resource" "this" {
  lifecycle {
    prevent_destroy = true
  }
}
```

Một số option hay gặp:

- `prevent_destroy`: chặn xóa nhầm resource quan trọng.
- `create_before_destroy`: tạo resource mới trước khi xóa resource cũ.
- `ignore_changes`: bỏ qua thay đổi ở một số field.

## 9. Nên Đặt Block Ở File Nào?

Terraform không bắt buộc tên file. Nó đọc tất cả file `.tf` trong cùng thư mục. Nhưng convention giúp project dễ đọc hơn:

| Block | File nên đặt |
| --- | --- |
| `terraform`, `required_providers` | `versions.tf` |
| `provider`, `backend` | `provider.tf` |
| `variable` | `variables.tf` |
| `locals` | `locals.tf` |
| `resource`, `data`, `module` | `main.tf` |
| `output` | `outputs.tf` |

Với project nhỏ, có thể chưa cần đủ file. Với project có root + child modules, nên tách file theo convention.

## 10. Checkpoint

Tự trả lời:

1. Provider khác resource ở điểm nào?
2. Data source khác resource ở điểm nào?
3. Vì sao `count = var.enable_rds ? 1 : 0` giúp bật/tắt module?
4. Khi nào dùng `for_each` thay vì `count`?
5. Vì sao provider nên để trong `provider.tf` khi project lớn?

