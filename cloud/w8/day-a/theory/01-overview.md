# 01 - Tổng Quan Terraform Và Infrastructure as Code

## Mục Tiêu

Sau phần này, cần trả lời được:

- Infrastructure as Code là gì?
- Vì sao Cloud/DevOps cần Terraform?
- Terraform khác gì so với thao tác thủ công trên AWS Console?
- Terraform nhìn hạ tầng theo mô hình nào?

## 1. Infrastructure as Code Là Gì?

Infrastructure as Code, viết tắt là IaC, là cách quản lý hạ tầng bằng file cấu hình thay vì thao tác thủ công trên giao diện.

Nếu làm thủ công, mình thường phải mở AWS Console, tạo từng tài nguyên như VPC, Subnet, Security Group, RDS, Lambda rồi tự ghi nhớ các bước đã bấm. Cách này nhanh lúc demo, nhưng rất dễ lệch cấu hình khi làm nhiều môi trường.

Nếu làm bằng IaC, mình viết cấu hình Terraform, commit lên Git, review thay đổi, chạy `terraform plan` để xem trước, rồi mới chạy `terraform apply` khi kế hoạch đã ổn.

Điểm khác biệt quan trọng: với IaC, hạ tầng trở thành code. Code đó có thể đọc lại, review, rollback, chạy lại và tự động hóa.

## 2. Vì Sao Không Nên Chỉ Dùng AWS Console?

AWS Console phù hợp để học nhanh hoặc kiểm tra tài nguyên, nhưng có nhiều vấn đề khi dùng cho project thật:

- Khó biết ai đã thay đổi gì.
- Khó tạo lại môi trường giống hệt.
- Dễ cấu hình lệch giữa dev, staging, production.
- Khó review trước khi thay đổi.
- Khó tự động hóa trong CI/CD.

Terraform giải quyết bằng cách đưa cấu hình hạ tầng vào Git.

Ví dụ thay vì nhớ trong đầu rằng project cần 2 private subnet, mình viết:

```hcl
private_subnets = {
  "private-app-a" = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-west-2a"
    type              = "app"
  }
}
```

Khi đọc file, mentor hoặc teammate biết chính xác hạ tầng mong muốn là gì.

## 3. Terraform Là Gì?

Terraform là công cụ IaC dùng để khai báo trạng thái mong muốn của hạ tầng.

Mình viết:

```text
Tôi muốn có một VPC
Tôi muốn có hai subnet private
Tôi muốn có một S3 bucket
Tôi muốn Lambda nằm trong subnet app
```

Terraform đọc các file `.tf`, đọc state hiện tại, hỏi provider về tài nguyên thật trên cloud, rồi so sánh trạng thái mong muốn trong code với trạng thái hiện tại. Từ đó Terraform tạo ra một bản plan; nếu plan được duyệt, Terraform mới apply thay đổi.

## 4. Các Khái Niệm Cốt Lõi

### Configuration

Configuration là các file `.tf` mình viết.

Ví dụ:

```text
main.tf
variables.tf
outputs.tf
provider.tf
```

### Provider

Provider là plugin giúp Terraform nói chuyện với một nền tảng.

Ví dụ:

- AWS provider để tạo VPC, S3, Lambda, RDS.
- Kubernetes provider để tạo Deployment, Service.
- GitHub provider để tạo repo, branch protection.

Ví dụ AWS provider:

```hcl
provider "aws" {
  region = var.aws_region
}
```

### Resource

Resource là tài nguyên thật mà Terraform quản lý.

Ví dụ:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = "my-demo-bucket"
}
```

Dòng này nói Terraform quản lý một S3 bucket.

### Variable

Variable là input truyền vào Terraform.

```hcl
variable "project_name" {
  description = "Tên dự án"
  type        = string
}
```

Dùng bằng:

```hcl
var.project_name
```

### Local

Local là giá trị tính toán nội bộ trong Terraform.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
```

Dùng bằng:

```hcl
local.name_prefix
```

### Output

Output là giá trị Terraform trả ra sau khi chạy.

```hcl
output "name_prefix" {
  description = "Tiền tố tên tài nguyên"
  value       = local.name_prefix
}
```

### State

State là file Terraform dùng để ghi nhớ tài nguyên nào đang được nó quản lý.

Ví dụ, state có thể ghi rằng `module.s3.aws_s3_bucket.this["frontend"]` đang tương ứng với một bucket thật trên AWS, còn `module.vpc.aws_vpc.this` đang tương ứng với một VPC thật.

Không có state, Terraform khó biết resource trong code tương ứng với resource nào ngoài AWS.

## 5. Terraform Workflow Tổng Quan

Một vòng làm việc cơ bản:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Ý nghĩa nhanh:

- `init`: khởi tạo provider, module, backend.
- `fmt`: format code.
- `validate`: kiểm tra cú pháp và tham chiếu.
- `plan`: xem trước thay đổi.
- `apply`: áp dụng thay đổi.

Khi cần xóa toàn bộ tài nguyên đang được state quản lý:

```bash
terraform destroy
```

Lệnh `destroy` nguy hiểm, thường chỉ chạy thủ công và phải kiểm tra kỹ.

## 6. Terraform Trong Repo Terraform_Hackathon

Repo `/home/kienlht/Terraform_Hackathon` có cấu trúc thực tế:

```text
environments/
  budget_bot/
    provider.tf
    variables.tf
    terraform.tfvars
    main.tf
    outputs.tf
modules/
  s3/
  vpc/
  lambda/
  api_gateway/
  rds/
  cloudfront/
```

Cách hiểu:

- `environments/budget_bot`: root module, nơi chạy Terraform.
- `modules/*`: child modules, mỗi module quản lý một nhóm tài nguyên.
- `terraform.tfvars`: giá trị thật cho môi trường.
- `main.tf`: nối các module với nhau.
- `outputs.tf`: xuất kết quả quan trọng.


