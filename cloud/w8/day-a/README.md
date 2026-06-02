# W8 Day A - Terraform Self-study

Phạm vi: T2 01/06

Thư mục này là bộ tài liệu tự học Terraform phần 1 cho W8 Foundation. Nội dung tập trung vào IaC overview, HCL syntax, variables, locals và outputs.

## Lịch Học

| Ngày | Trọng tâm | Evidence |
| --- | --- | --- |
| T2 01/06 | Terraform phần 1: IaC overview + HCL syntax | Đọc `theory/01-overview.md`, `theory/02-hcl-syntax.md`, làm `exercises/t2-hcl-basics`, cập nhật reflection |

## Cấu Trúc Thư Mục

```text
day-a/
  README.md
  theory/
    01-overview.md
    02-hcl-syntax.md
  exercises/
    t2-hcl-basics/
      versions.tf
      variables.tf
      locals.tf
      outputs.tf
      README.md
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

Terraform phần 2 nằm ở `cloud/w8/day-c`.

## Commit Gợi Ý

```text
[W8-D1] Add Terraform HCL basics study notes and exercises
```
