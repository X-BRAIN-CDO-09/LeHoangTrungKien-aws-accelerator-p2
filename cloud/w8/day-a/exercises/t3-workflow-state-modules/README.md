# Bài Tập T3 - Workflow, State, Modules

Bài tập này nối kiến thức Terraform workflow và luồng dữ liệu module với repo `Terraform_Hackathon`. Bài tập có một root module mini và một child module để có thể chạy local mà không cần AWS credentials.

## Các File Trong Bài Tập

```text
t3-workflow-state-modules/
  versions.tf
  variables.tf
  terraform.tfvars
  main.tf
  outputs.tf
  modules/
    naming/
      variables.tf
      locals.tf
      outputs.tf
```

Trong bài tập mini, `terraform.tfvars` cung cấp dữ liệu cho root module. Root `main.tf` gọi `module "naming"`, child module nhận input trong `modules/naming/variables.tf`, tính toán trong `locals.tf`, trả kết quả ở `outputs.tf`, rồi root module xuất lại kết quả trong root `outputs.tf`.

Chạy:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan
```

## File Cần Đọc Trong Terraform_Hackathon

Đọc các file sau trong `/home/kienlht/Terraform_Hackathon`:

```text
AI_TERRAFORM_GUIDE.md
environments/budget_bot/provider.tf
environments/budget_bot/variables.tf
environments/budget_bot/terraform.tfvars
environments/budget_bot/main.tf
environments/budget_bot/outputs.tf
modules/s3/variables.tf
modules/s3/main.tf
modules/s3/outputs.tf
modules/vpc/variables.tf
modules/vpc/main.tf
modules/vpc/outputs.tf
modules/lambda/variables.tf
modules/lambda/main.tf
modules/lambda/outputs.tf
modules/api_gateway/variables.tf
modules/api_gateway/main.tf
modules/api_gateway/outputs.tf
```

## Vẽ Luồng Dữ Liệu

Viết lại bằng lời của mình trong `cloud/w8/reflection.md`: dữ liệu đi từ `terraform.tfvars` vào root variables, được dùng trong root `main.tf`, truyền vào module input, tạo hoặc tính toán resource trong module, sau đó quay lại qua module output. Output đó có thể được truyền tiếp sang module khác hoặc xuất ra root output.

Dùng ví dụ S3 sang Lambda: `project_name` được truyền vào `module.s3`, module S3 trả về `module.s3.bucket_ids["csv-data"]`, root module đưa bucket này vào `local.dynamic_lambdas`, rồi truyền cấu hình đó sang `module.lambda`. Kết quả cuối cùng là Lambda có environment variable `STORAGE_BUCKET`.

## Checkpoint Workflow

Giải thích các lệnh:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform destroy
```

Với mỗi lệnh, trả lời:

- Lệnh này có thay đổi tài nguyên AWS thật không?
- Lệnh này có đọc hoặc ghi state không?
- Lệnh này nên chạy lúc nào trong CI/CD?

## Checkpoint State

Giải thích backend này:

```hcl
backend "s3" {
  bucket       = "budgetbot-tfstate-hackathon-w7"
  key          = "budget_bot/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
```

Câu hỏi:

- Vì sao dùng S3 thay vì local state?
- Vì sao state cần được mã hóa?
- Vì sao locking quan trọng?
- Vì sao không commit state lên Git?

## Checkpoint Module

Chọn một module trong `Terraform_Hackathon` và trả lời:

- Module này cần input gì?
- Module này tạo resource nào?
- Module này trả output gì?
- Module nào khác dùng output đó?

Module gợi ý: `modules/s3`.

## Evidence Cần Ghi Lại

Ghi vào `cloud/w8/reflection.md`:

- Giải thích các lệnh Terraform workflow.
- Giải thích state/backend S3.
- Luồng dữ liệu S3 sang Lambda.
- Một best practice từ `AI_TERRAFORM_GUIDE.md` mà mình muốn áp dụng khi viết Terraform sau này.
