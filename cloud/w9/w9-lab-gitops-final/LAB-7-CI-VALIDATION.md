# Lab 7 - CI Validation và Branch Protection

## Mục tiêu

Mọi thay đổi Kubernetes manifest cần được kiểm tra trước khi merge vào `main`.

Workflow chạy thật nằm tại:

```text
.github/workflows/w9-gitops-validate.yml
```

GitHub Actions chỉ tự động đọc workflow trong `.github/workflows` ở root repository.

## Workflow thực hiện gì?

Khi Pull Request thay đổi file trong:

```text
cloud/w9/w9-lab-gitops-final/k8s/**
cloud/w9/w9-lab-gitops-final/flipkart/k8s/**
cloud/w9/w9-lab-gitops-final/argocd/**
```

workflow sẽ:

1. Checkout repository.
2. Tải `kubeconform`.
3. Strict validate các Kubernetes manifests.
4. Validate ArgoCD Application manifests và bỏ qua schema CRD chưa có sẵn.

Workflow chỉ kiểm tra YAML. Workflow không apply resource vào cluster.

## Bước 1 - Commit workflow bằng branch riêng

```bash
git switch -c w9-lab7-ci-validation

git add .github/workflows/w9-gitops-validate.yml
git add cloud/w9/w9-lab-gitops-final/LAB-7-CI-VALIDATION.md

git commit -m "[W9-Lab] Add GitOps manifest validation"
git push -u origin w9-lab7-ci-validation
```

Tạo Pull Request từ:

```text
w9-lab7-ci-validation -> main
```

Kiểm tra tab Actions hoặc Checks trên Pull Request. Job cần chuyển sang màu xanh.

## Bước 2 - Thử manifest sai

Tạo branch mới sau khi workflow đã có trên `main`:

```bash
git switch main
git pull
git switch -c w9-lab7-invalid-manifest
```

Trong `k8s/web.yaml`, cố tình viết sai:

```yaml
replicas: "not-a-number"
```

Push và tạo Pull Request:

```bash
git add cloud/w9/w9-lab-gitops-final/k8s/web.yaml
git commit -m "[W9-Lab] Test invalid Kubernetes manifest"
git push -u origin w9-lab7-invalid-manifest
```

Kết quả mong đợi:

```text
Validate Kubernetes manifests: Failed
```

Sau khi quan sát lỗi, sửa `replicas` về số hợp lệ và push lại. Workflow sẽ chạy lại và pass.

## Bước 3 - Bật Branch Protection

Trong GitHub repository:

```text
Settings
-> Branches hoặc Rules
-> Add branch protection rule / ruleset
```

Cấu hình cho branch:

```text
main
```

Bật:

- Require a pull request before merging.
- Require approvals nếu tài khoản/tổ chức hỗ trợ.
- Require status checks to pass before merging.
- Chọn status check `Validate Kubernetes and ArgoCD manifests`.

## Hoàn thành khi

- Pull Request có manifest hợp lệ được CI xác nhận xanh.
- Pull Request có manifest sai bị CI chặn.
- Không thể merge khi required status check chưa pass.
- CI chỉ validate; ArgoCD vẫn là thành phần thực hiện CD vào cluster.

## Luồng hoàn chỉnh

```text
Developer sửa manifest
-> mở Pull Request
-> kubeconform validate
-> review và merge
-> ArgoCD phát hiện main thay đổi
-> ArgoCD sync cluster
```
