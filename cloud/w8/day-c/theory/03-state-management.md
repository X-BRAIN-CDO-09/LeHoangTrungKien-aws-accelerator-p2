# 03 - Terraform Workflow Và State Management

## Mục Tiêu

Sau phần này, mình cần hiểu:

- Các lệnh `init`, `fmt`, `validate`, `plan`, `apply`, `destroy`.
- Terraform state là gì.
- Vì sao team cần remote state.
- Vì sao không commit state lên Git.

## 1. Workflow Cơ Bản

Một vòng Terraform thường là:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Khi muốn xóa hạ tầng:

```bash
terraform destroy
```

## 2. `terraform init`

`init` khởi tạo project Terraform.

Nó làm các việc:

- Tải provider.
- Tải module nếu dùng module bên ngoài.
- Khởi tạo backend state.
- Tạo thư mục `.terraform/`.

Chạy `init` khi:

- Vừa clone repo.
- Thay đổi provider.
- Thay đổi backend.
- Thêm module mới.

Ví dụ:

```bash
terraform init -backend=false
```

Trong bài học local, dùng `-backend=false` để không kết nối backend remote.

## 3. `terraform fmt`

`fmt` format file Terraform.

```bash
terraform fmt -recursive
```

Trong CI/CD thường dùng:

```bash
terraform fmt -check -recursive
```

`-check` chỉ kiểm tra, không tự sửa file.

## 4. `terraform validate`

`validate` kiểm tra cấu hình.

Nó bắt lỗi:

- Sai cú pháp.
- Sai kiểu dữ liệu.
- Tham chiếu tới biến hoặc output không tồn tại.
- Module input thiếu hoặc sai.

Nó không tạo AWS resource.

## 5. `terraform plan`

`plan` là bước xem trước.

Khi chạy `plan`, Terraform đọc cấu hình trong các file `.tf`, đọc state, refresh thông tin từ tài nguyên thật, rồi so sánh desired state với current state. Kết quả cuối cùng là một kế hoạch thay đổi để mình review trước khi apply.

Ký hiệu thường gặp:

- `+`: tạo mới.
- `~`: cập nhật.
- `-`: xóa.
- `-/+`: thay thế.

Production nên lưu plan:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Cách này đảm bảo apply đúng plan đã review.

## 6. `terraform apply`

`apply` thực hiện thay đổi thật.

Nó có thể:

- Tạo resource.
- Sửa resource.
- Xóa resource.
- Thay thế resource.
- Ghi state mới.
- In root outputs.

Vì `apply` thay đổi hạ tầng thật, cần đọc `plan` trước khi chạy.

## 7. `terraform destroy`

`destroy` xóa toàn bộ resource đang nằm trong state hiện tại.

Nguy hiểm:

- Có thể xóa cả môi trường.
- Có thể làm mất database nếu không có backup/snapshot.
- Không nên tự động chạy trên mọi push.

Workflow destroy nên là manual workflow có kiểm soát.

## 8. State Là Gì?

State là file Terraform dùng để ghi nhớ tài nguyên thật.

Ví dụ Terraform address:

```text
module.s3.aws_s3_bucket.this["frontend"]
```

có thể map tới resource thật:

```text
budget-bot-frontend-a1b2c3
```

State giúp Terraform biết:

- Resource nào đã được tạo.
- Resource nào thuộc Terraform.
- Thuộc tính hiện tại của resource.
- Cần thay đổi gì khi plan.

## 9. Vì Sao Không Commit State?

Không commit state vì:

- State có thể chứa dữ liệu nhạy cảm.
- State thay đổi sau mỗi apply.
- Nhiều người commit state sẽ dễ conflict.
- CI/CD và máy cá nhân có thể ghi đè nhau.

Nên ignore:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
```

## 10. Local State Và Remote State

Local state:

```text
terraform.tfstate nằm trong máy cá nhân
```

Phù hợp:

- Bài học nhỏ.
- Demo local.
- Exercise không tạo resource thật.

Không phù hợp:

- Làm team.
- Production.
- CI/CD.

Remote state:

```text
terraform.tfstate nằm trong backend như S3
```

Phù hợp:

- Team cùng dùng chung state.
- CI/CD đọc và ghi state.
- Có locking.
- Có versioning/encryption.

## 11. Backend S3 Trong Terraform_Hackathon

Ví dụ:

```hcl
terraform {
  backend "s3" {
    bucket       = "budgetbot-tfstate-hackathon-w7"
    key          = "budget_bot/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Giải thích:

```hcl
backend "s3"
```

Terraform lưu state trong S3.

```hcl
bucket = "budgetbot-tfstate-hackathon-w7"
```

S3 bucket chứa state.

```hcl
key = "budget_bot/terraform.tfstate"
```

Đường dẫn file state trong bucket. Mỗi environment nên có key riêng.

```hcl
region = "us-east-1"
```

Region của bucket state.

```hcl
encrypt = true
```

Mã hóa state.

```hcl
use_lockfile = true
```

Khóa state khi đang apply để tránh nhiều process ghi cùng lúc.

## 12. Luồng Khi Chạy Plan/Apply

Khi chạy `terraform plan`, Terraform đọc code, đọc remote state, gọi AWS để refresh thông tin tài nguyên thật, rồi so sánh cấu hình mong muốn với hiện trạng. Nếu có khác biệt, Terraform in ra kế hoạch tạo, sửa, xóa hoặc thay thế resource.

Khi chạy `terraform apply`, Terraform thực thi dependency graph theo đúng thứ tự cần thiết. Sau khi tạo, sửa hoặc xóa resource, Terraform ghi state mới và in các root output.

## 13. Checklist Sau Khi Đọc

Tự trả lời:

1. `init` tạo gì trên máy local?
2. `validate` có gọi AWS để tạo resource không?
3. `plan` dùng state để làm gì?
4. Vì sao remote state cần locking?
5. Vì sao `destroy` phải được bảo vệ?
