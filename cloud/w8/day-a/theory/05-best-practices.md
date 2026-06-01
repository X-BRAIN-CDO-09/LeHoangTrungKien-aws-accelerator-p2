# 05 - Best Practices Terraform

## Mục Tiêu

Sau phần này, mình cần nắm các nguyên tắc viết Terraform sạch hơn:

- Tách giá trị dynamic và static.
- Quản lý tag tập trung.
- Dùng type rõ ràng cho variables.
- Đưa logic phức tạp vào `locals`.
- Không commit state, secret, plan artifact.
- CI/CD nên chạy fmt, validate, plan, apply như thế nào.

## 1. Tách Dynamic Và Static Values

Dynamic values là giá trị thay đổi theo môi trường.

Ví dụ:

- `aws_region`
- `vpc_cidr`
- `availability_zones`
- `instance_type`
- `db_instance_class`
- `desired_count`
- `rds_multi_az`

Các giá trị này nên nằm ở:

```text
environments/<env>/variables.tf
environments/<env>/terraform.tfvars
```

Static values là chuẩn kỹ thuật ít thay đổi.

Ví dụ:

- HTTP port `80`.
- Database port `3306`.
- ECR `scan_on_push = true`.
- ECS network mode `awsvpc`.
- Health check path `/`.
- Storage type `gp3`.

Các giá trị này thường nên hardcode trong module để module interface gọn hơn.

## 2. Khi Nào Không Nên Dùng `default`

Không nên dùng `default` cho giá trị quan trọng theo môi trường.

Ví dụ không nên:

```hcl
variable "vpc_cidr" {
  description = "Dải IP của VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

Lý do: nếu quên truyền giá trị, Terraform âm thầm dùng default và có thể deploy sai network.

Nên viết:

```hcl
variable "vpc_cidr" {
  description = "Dải IP của VPC"
  type        = string
}
```

Rồi truyền trong `terraform.tfvars`:

```hcl
vpc_cidr = "10.0.0.0/16"
```

## 3. Quản Lý Tag Tập Trung

Trong AWS provider có thể dùng `default_tags`.

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "W7Capstone"
      Team        = "G9"
      Owner       = "G9"
      Environment = "hackathon"
    }
  }
}
```

Lợi ích:

- Không phải truyền `tags` qua mọi module.
- Resource có metadata nhất quán.
- Dễ filter chi phí và ownership trên AWS.

Ngoại lệ:

- Auto Scaling Group và EC2 sinh bởi ASG có thể cần tag propagation riêng.

## 4. Dùng Type Rõ Ràng

Nên khai báo type chặt:

```hcl
variable "routes" {
  description = "Bản đồ route API Gateway"
  type = map(object({
    route_key         = string
    lambda_key        = string
    enable_authorizer = optional(bool, false)
  }))
}
```

Không nên dùng `any` nếu đã biết cấu trúc:

```hcl
variable "routes" {
  type = any
}
```

Type rõ giúp:

- Bắt lỗi sớm.
- Người đọc hiểu input contract.
- CI/CD fail trước khi apply.

## 5. Đưa Logic Phức Tạp Vào `locals`

Không nên nhét logic dài trực tiếp vào resource.

Khó đọc:

```hcl
for_each = { for k, v in var.private_subnets : k => v if v.nat_gateway_route_to != null }
```

Dễ đọc hơn:

```hcl
locals {
  private_subnets_with_nat = {
    for k, v in var.private_subnets : k => v
    if v.nat_gateway_route_to != null
  }
}
```

Sau đó:

```hcl
for_each = local.private_subnets_with_nat
```

Lợi ích:

- Resource block sạch hơn.
- Logic có tên rõ ràng.
- Dễ debug khi đọc code.

## 6. Module Interface Nên Nhỏ Và Rõ

Một module tốt nên trả lời được:

- Input cần gì?
- Resource tạo gì?
- Output trả gì?

Không nên expose quá nhiều biến chỉ để "cho linh hoạt". Linh hoạt quá mức làm module khó dùng.

Ví dụ:

- DB port luôn là `3306` nếu module cố định MySQL.
- ALB listener protocol có thể hardcode `HTTP` nếu scope lab chỉ dùng HTTP.
- Health check path `/` có thể hardcode nếu app thống nhất.

Chỉ biến thứ thật sự thay đổi theo environment thành variable.

## 7. Không Commit File Nhạy Cảm Hoặc Artifact

Nên ignore:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
*.log
```

Không commit:

- Access key.
- Secret.
- Password.
- State.
- Plan file.
- `.terraform/`.
- File zip build tạm.

## 8. CI/CD Terraform

Một pipeline cơ bản thường bắt đầu bằng checkout code, cấu hình AWS credentials, cài Terraform, rồi chạy lần lượt `terraform init`, `terraform fmt -check`, `terraform validate` và `terraform plan`. Bước `terraform apply` chỉ nên chạy khi branch hoặc event đã được kiểm soát rõ ràng.

Nguyên tắc:

- Pull request nên chạy `fmt`, `validate`, `plan`.
- Apply chỉ nên chạy trên branch/event được kiểm soát.
- Destroy nên là workflow thủ công.
- Dùng OIDC role thay vì long-lived access key.

## 9. Best Practices Từ Terraform_Hackathon

Trong `/home/kienlht/Terraform_Hackathon/AI_TERRAFORM_GUIDE.md`, các ý chính:

- Environment-specific values đặt ở root environment.
- Invariant values hardcode trong module.
- Dùng provider `default_tags`.
- Description của variables/outputs viết tiếng Việt.
- Logic filter/iteration phức tạp đưa vào `locals`.
- Trước khi commit chạy `terraform fmt -recursive` và `terraform validate`.

## 10. Checklist Trước Khi Commit

Tự kiểm tra:

- File `.tf` đã format chưa?
- `terraform validate` có pass không?
- Có commit state hoặc `.terraform/` không?
- Variable/output có description rõ không?
- Giá trị nhạy cảm có bị hardcode không?
- Module input có đang quá rộng không?
- Output có expose quá nhiều thông tin không?
- Plan có tạo/xóa gì bất ngờ không?

## 11. Suggested Evidence Cho W8

Trong `cloud/w8/reflection.md`, ghi lại:

- Đã đọc các file theory nào.
- Đã chạy exercise T2/T3 nào.
- Kết quả `terraform plan` là gì.
- Một best practice học được từ `Terraform_Hackathon`.
- Một câu hỏi muốn hỏi mentor trong buổi live Terraform.
