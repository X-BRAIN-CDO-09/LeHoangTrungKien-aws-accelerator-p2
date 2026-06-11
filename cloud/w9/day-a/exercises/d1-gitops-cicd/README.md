# Bài thực hành D1 - GitOps và CI/CD

## Mục tiêu

- Tạo workflow GitHub Actions cho plan-on-PR và apply-on-merge.
- Tạo ArgoCD root application theo mô hình App of Apps.
- Tạo child application cho demo app.
- Ghi lại cách rollback phù hợp với GitOps.

## Cấu trúc

```text
d1-gitops-cicd/
  .github/workflows/terraform-plan-apply.yml  # Bản tham khảo đặt cùng bài học
  argocd/app-of-apps.yaml
  argocd/apps/demo-app.yaml
  manifests/demo-app.yaml
  demo-app-yaml-explained.md
  rollback-notes.md
```

## Các bước thực hành

1. Kiểm tra workflow GitHub Actions.
2. Đọc `demo-app-yaml-explained.md` và đối chiếu với manifest.
3. Cập nhật `repoURL` trong hai manifest ArgoCD.
4. Apply root application vào namespace `argocd`.
5. Kiểm tra ArgoCD sync child application.
6. Thay đổi image hoặc replicas trong Git và quan sát ArgoCD sync.
7. Thực hành rollback bằng `git revert`.

## Điều kiện trước khi chạy

- `kubectl` đang trỏ đến kind cluster của W8.
- ArgoCD đã được cài trong namespace `argocd`.
- Repository có thể được ArgoCD đọc.
- Các file Day A đã được commit và push lên nhánh `main`.

## Thứ tự chạy đề xuất

### 1. Kiểm tra demo app W8 hiện tại

```bash
kubectl get deployment,service,pods
kubectl get service demo-app -o wide
```

Kết quả cần thấy là Deployment và Service `demo-app`, trong đó Service dùng NodePort `30080`.

### 2. Kiểm tra repository URL

Hai ArgoCD Application đã trỏ đến repository:

```text
https://github.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2.git
```

ArgoCD đọc manifest từ remote Git repository, không đọc trực tiếp file đang nằm trên máy local.

Nếu repository là private, cần đăng ký repository credential trong ArgoCD trước khi sync.

### 3. Commit và push manifest

```bash
git add cloud/w9/day-a/exercises/d1-gitops-cicd
git commit -m "[W9-D1] GitOps manage W8 demo app"
git push
```

### 4. Cài ArgoCD vào kind cluster W8

W8 chưa cài ArgoCD. Cài controller và các CRD trước:

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
kubectl get pods -n argocd
```

Truy cập UI bằng port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Sau đó mở:

```text
https://localhost:8080
```

### 5. Tạo root Application

```bash
kubectl apply -f argocd/app-of-apps.yaml
```

Root Application sẽ đọc thư mục `argocd/apps` và tạo child Application `demo-app`.

### 6. Theo dõi ArgoCD sync

```bash
kubectl get applications -n argocd
argocd app get demo-app
argocd app sync demo-app
```

Sau khi sync, ArgoCD sẽ quản lý Deployment và Service W8 đang tồn tại vì tên resource và namespace trùng khớp.

### 7. Kiểm tra workload sau khi sync

```bash
kubectl get deployment,service,pods
kubectl rollout status deployment/demo-app --timeout=180s
kubectl get endpoints demo-app
```

### 8. Luyện thay đổi qua Git

Thay `replicas: 2` thành `replicas: 3`, commit và push. Không chạy `kubectl apply` cho manifest workload.

Quan sát:

```bash
argocd app get demo-app
kubectl get deployment demo-app
kubectl get pods -l app=demo-app
```

ArgoCD sẽ phát hiện desired state mới và tăng số Pod lên 3.

## Lệnh tham khảo

```bash
kubectl apply -f argocd/app-of-apps.yaml
kubectl get applications -n argocd
argocd app get demo-app
argocd app sync demo-app
kubectl get deployment,service,pods
kubectl rollout status deployment/demo-app --timeout=180s
```

## Demo App W8 được tái sử dụng như thế nào?

- Dùng image public `docker.io/kienlht/k8s-demo-app:v1`.
- Giữ Deployment và Service tên `demo-app`.
- Giữ namespace `default`.
- Giữ `NodePort 30080` để tương thích với ALB và kind port mapping của W8.
- Chuyển desired state từ file tạm do user data tạo sang YAML được ArgoCD quản lý trong Git.

## Hai file demo-app.yaml khác nhau như thế nào?

### `argocd/apps/demo-app.yaml`

Đây là ArgoCD `Application`. File này không trực tiếp tạo Pod hoặc Service. Nó hướng dẫn ArgoCD:

- Đọc repository nào.
- Đọc manifest ở thư mục nào.
- Deploy vào cluster và namespace nào.
- Có tự động sync, prune và self-heal hay không.

### `manifests/demo-app.yaml`

Đây là Kubernetes workload manifest. File này mô tả tài nguyên thực sự cần chạy:

- Deployment tạo và duy trì Pod.
- Service NodePort chuyển traffic đến Pod.
- Image, probes, resources, replicas và ports.

Luồng liên kết:

```text
ArgoCD Application
-> đọc thư mục manifests
-> apply Kubernetes Deployment và Service
```

## Workflow CI/CD nằm ở đâu?

GitHub chỉ chạy workflow nằm tại `.github/workflows/` ở root repository.

- Workflow chạy thật: `.github/workflows/w9-terraform-ci.yml`
- Workflow trong bài tập: `cloud/w9/day-a/exercises/d1-gitops-cicd/.github/workflows/terraform-plan-apply.yml`

Bản trong bài tập được giữ để học cấu trúc. Bản ở root mới xuất hiện trong tab GitHub Actions.

Xem giải thích chi tiết tại `cicd-workflow-explained.md`.

## Tham khảo từ terraform_xbrain

Workflow W9 sử dụng các ý phù hợp từ `terraform_xbrain`:

- Xác thực AWS bằng GitHub OIDC.
- `permissions: id-token: write`.
- Dùng secret `TF_AWS_ROLE_ARN`.
- Giới hạn workflow theo branch và path.
- Thêm `workflow_dispatch` và `concurrency`.
- Chạy format, init, validate, plan trước khi apply.

### GitHub configuration cần tạo

Repository secret:

```text
TF_AWS_ROLE_ARN=<ARN của IAM role cho GitHub Actions>
```

Repository variables:

```text
AWS_REGION=ap-southeast-1
ENABLE_TERRAFORM_APPLY=false
```

Giữ `ENABLE_TERRAFORM_APPLY=false` khi W8 còn dùng local Terraform state. Chỉ bật apply tự động sau khi đã chuyển state sang remote backend, nếu không runner mới có thể không biết hạ tầng đã tồn tại.
