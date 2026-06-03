# W8 Day C - Terraform Workflow, State, Modules

Phạm vi: T4 03/06

Theo lịch W8 mới, T4 là ngày học Terraform phần 2: State Management, Modules, Best Practices, ADR và chuẩn bị câu hỏi cho mentor Minh trước buổi live 15h-17h.

## Lịch Học

| Ngày | Trọng tâm | Evidence |
| --- | --- | --- |
| T4 03/06 | Terraform phần 2: workflow + state + modules + best practices | Đọc theory, làm `exercises/t4-workflow-state-modules`, chuẩn bị 2-3 câu hỏi cho mentor Minh |

## Cấu Trúc

```text
day-c/
  README.md
  theory/
    03-state-management.md
    04-modules.md
    05-best-practices.md
    06-terraform-building-blocks.md
  exercises/
    t4-workflow-state-modules/
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
      practice-tf/
        01-root-child-module/
        02-module-output-chain/
        03-backend-skeleton/
        04-provider-resource-data-meta/
```

## Lệnh Kiểm Tra

```bash
cd cloud/w8/day-c/exercises/t4-workflow-state-modules
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan
```

## Commit Gợi Ý

```text
[W8-D3] Add Terraform workflow state and module exercises
```

