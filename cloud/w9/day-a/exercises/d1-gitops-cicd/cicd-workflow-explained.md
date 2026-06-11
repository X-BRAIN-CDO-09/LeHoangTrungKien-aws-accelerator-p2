# Giải thích Workflow Terraform CI/CD

## Hai bản workflow

```text
.github/workflows/w9-terraform-ci.yml
```

Đây là workflow chạy thật vì GitHub Actions chỉ đọc workflow trong `.github/workflows` ở root repository.

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/.github/workflows/terraform-plan-apply.yml
```

Đây là bản tham khảo đặt cạnh bài học để dễ đọc và đối chiếu.

## Nguồn tham khảo terraform_xbrain

Workflow được điều chỉnh từ các ý chính trong `terraform_xbrain/.github/workflows/terraform-ci.yml`:

- Xác thực AWS bằng OIDC.
- Cấp `id-token: write` cho workflow.
- Dùng `TF_AWS_ROLE_ARN` thay vì lưu access key dài hạn.
- Chạy Terraform theo thứ tự fmt, init, validate, plan và apply.
- Chỉ apply khi push vào nhánh `main`.
- Dùng path filter để tránh chạy workflow khi file không liên quan thay đổi.
- Dùng concurrency để tránh nhiều workflow cùng thay đổi hạ tầng.

Không copy nguyên workflow `terraform_xbrain` vì cấu trúc hạ tầng và backend của hai repository khác nhau.

## Trigger

```yaml
on:
  pull_request:
    branches:
      - main
  push:
    branches:
      - main
  workflow_dispatch:
```

- Pull request vào `main`: workflow kiểm tra và chạy plan.
- Push vào `main`: workflow chạy lại plan và có thể apply.
- `workflow_dispatch`: cho phép chạy thủ công từ GitHub Actions.

Path filter chỉ cho workflow chạy khi W8 lab hoặc chính workflow thay đổi.

## Concurrency

```yaml
concurrency:
  group: w9-terraform-${{ github.ref }}
  cancel-in-progress: false
```

Concurrency giúp tránh hai workflow trên cùng một branch cùng chạy Terraform. Không hủy workflow đang chạy vì Terraform apply bị dừng giữa chừng có thể để lại trạng thái khó xử lý.

## Permissions và OIDC

```yaml
permissions:
  id-token: write
  contents: read
```

- `contents: read`: cho phép checkout repository.
- `id-token: write`: cho phép GitHub Actions nhận OIDC token để assume IAM role trên AWS.

Workflow dùng:

```yaml
uses: aws-actions/configure-aws-credentials@v4
```

với:

```yaml
role-to-assume: ${{ secrets.TF_AWS_ROLE_ARN }}
```

AWS IAM role cần trust đúng repository:

```text
repo:X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2:*
```

## Working directory

```yaml
defaults:
  run:
    working-directory: cloud/w8/lab
```

Mọi lệnh Terraform được chạy trong W8 lab vì đây là hạ tầng cần kiểm tra.

## Các bước Terraform

### Format check

```bash
terraform fmt -check -recursive
```

Kiểm tra code Terraform đã được format thống nhất chưa. Lệnh không tự sửa file trong CI.

### Init

```bash
terraform init -input=false
```

Tải provider và khởi tạo backend. `-input=false` ngăn workflow chờ nhập dữ liệu tương tác.

### Validate

```bash
terraform validate
```

Kiểm tra cấu trúc và tính hợp lệ của Terraform configuration.

### Plan

```bash
terraform plan -no-color -input=false
```

Hiển thị Terraform dự định tạo, sửa hoặc xóa tài nguyên nào. `-no-color` giúp log GitHub Actions dễ đọc.

### Apply

```yaml
if: github.event_name == 'push' &&
    github.ref == 'refs/heads/main' &&
    vars.ENABLE_TERRAFORM_APPLY == 'true'
```

Apply chỉ chạy khi:

1. Event là push.
2. Branch là main.
3. Repository variable `ENABLE_TERRAFORM_APPLY` bằng `true`.

## Vì sao mặc định chưa bật Apply?

W8 lab hiện chưa khai báo remote Terraform backend. GitHub-hosted runner là máy tạm thời và sẽ mất local state sau khi workflow kết thúc.

Nếu lần sau chạy apply mà không có state cũ, Terraform có thể nghĩ hạ tầng chưa tồn tại và cố tạo lại tài nguyên.

Do đó cần giữ:

```text
ENABLE_TERRAFORM_APPLY=false
```

Khi đã cấu hình remote state an toàn, có thể cân nhắc bật:

```text
ENABLE_TERRAFORM_APPLY=true
```

## Thiết lập GitHub repository

Tạo secret:

```text
TF_AWS_ROLE_ARN=<IAM role ARN được phép chạy Terraform>
```

Tạo variables:

```text
AWS_REGION=ap-southeast-1
ENABLE_TERRAFORM_APPLY=false
```

## CI/CD và GitOps phối hợp thế nào?

Hai luồng giải quyết hai phạm vi khác nhau:

```text
Terraform CI/CD
-> quản lý hạ tầng AWS và kind host của W8

ArgoCD GitOps
-> quản lý Deployment và Service bên trong Kubernetes
```

GitHub Actions không cần chạy `kubectl apply` cho demo app. ArgoCD sẽ đọc manifest trong Git và tự sync workload vào cluster.
