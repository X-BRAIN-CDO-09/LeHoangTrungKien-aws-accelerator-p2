# W8 Day A - Terraform Self-study

Phạm vi: T2 01/06 và T3 02/06

Thư mục này là bộ tài liệu tự học Terraform cho W8 Foundation. Nội dung được chia thành các file lý thuyết nhỏ, bài tập thực hành, và checkpoint evidence để dễ đọc và dễ commit cuối ngày.

## Lịch Học

| Ngày | Trọng tâm | Evidence |
| --- | --- | --- |
| T2 01/06 | Terraform phần 1: IaC overview + HCL syntax | Đọc `theory/01-overview.md`, `theory/02-hcl-syntax.md`, làm `exercises/t2-hcl-basics`, cập nhật reflection |
| T3 02/06 | Terraform phần 2: workflow + state + modules + best practices | Đọc `theory/03-state-management.md`, `theory/04-modules.md`, `theory/05-best-practices.md`, làm `exercises/t3-workflow-state-modules`, cập nhật reflection |

## Cấu Trúc Thư Mục

```text
day-a/
  README.md
  theory/
    01-overview.md
    02-hcl-syntax.md
    03-state-management.md
    04-modules.md
    05-best-practices.md
  exercises/
    t2-hcl-basics/
      versions.tf
      variables.tf
      locals.tf
      outputs.tf
      README.md
    t3-workflow-state-modules/
      versions.tf
      variables.tf
      terraform.tfvars
      main.tf
      outputs.tf
      README.md
      modules/naming/
        variables.tf
        locals.tf
        outputs.tf
```

## Lệnh Kiểm Tra

Exercise T2:

```bash
cd cloud/w8/day-a/exercises/t2-hcl-basics
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan
```

Exercise T3:

```bash
cd cloud/w8/day-a/exercises/t3-workflow-state-modules
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan
```
