# Hướng dẫn thực hành W9 buổi sáng - GitOps

## Tài liệu gốc

Mở file:

```text
W9-sang-gitops-final.html
```

Tài liệu gốc sử dụng Minikube local và một ứng dụng nginx đơn giản. Project hiện tại điều chỉnh bài lab để tái sử dụng:

- Hạ tầng Terraform W8.
- Kind cluster chạy trên EC2.
- Demo app W8 tại Docker Hub.
- AWS Systems Manager Session Manager thay cho SSH.
- Repository:

```text
https://github.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2.git
```

## Kiến trúc thực hành

```text
Local machine
  |
  | git push
  v
GitHub repository
  |
  | ArgoCD pull và reconcile
  v
ArgoCD trong kind cluster trên EC2
  |
  v
Deployment + Service demo-app
  |
  v
ALB -> EC2 NodePort 30080 -> demo-app Pods
```

## Phân biệt nơi chạy lệnh

### Chạy trên máy local

- Terraform.
- Git commit và push.
- AWS CLI để mở Session Manager.
- Chỉnh sửa YAML trong repository.

### Chạy trong EC2 qua Session Manager

- `kubectl`.
- Cài ArgoCD vào kind cluster.
- Quan sát Application, Deployment và Pod.
- Thử thay đổi trực tiếp cluster để kiểm tra self-heal.

---

# Lab 0 - Chuẩn bị W8 Platform

## Trên local

```bash
cd cloud/w8/lab
terraform init
terraform validate
terraform plan
terraform apply
```

Lấy lệnh Session Manager:

```bash
terraform output -raw ssm_start_session_command
```

## Mở Session Manager

```bash
aws ssm start-session \
  --target "$(terraform output -raw ec2_instance_id)" \
  --region ap-southeast-1
```

## Trong EC2

```bash
sudo -i
export KUBECONFIG=/root/.kube/config
kubectl get nodes
kubectl get deployment,service,pods
```

Hoàn thành khi:

- Kind node ở trạng thái `Ready`.
- Demo app W8 đang chạy.
- Service dùng NodePort `30080`.

---

# Lab 1 - Cài ArgoCD

## Trong EC2

```bash
kubectl create namespace argocd

kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl rollout status deployment/argocd-server \
  -n argocd \
  --timeout=300s

kubectl get pods -n argocd
```

Hoàn thành khi các Pod `argocd-*` ở trạng thái `Running`.

---

# Lab 2 - Tạo ArgoCD Application

## File cần hiểu

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/argocd/apps/demo-app.yaml
```

File này hướng dẫn ArgoCD:

- Đọc repository nào.
- Đọc Kubernetes manifests ở thư mục nào.
- Đồng bộ vào cluster và namespace nào.
- Tự động prune và self-heal hay không.

## Trên local

Push các file Day A lên Git:

```bash
git add cloud/w9/day-a
git commit -m "[W9-D1] Add GitOps demo app"
git push origin main
```

## Trong EC2

Để luyện đúng thứ tự trong slide, apply child Application bằng tay lần đầu:

```bash
kubectl apply -f /path/to/repo/cloud/w9/day-a/exercises/d1-gitops-cicd/argocd/apps/demo-app.yaml
kubectl get applications -n argocd
kubectl describe application demo-app -n argocd
```

Nếu EC2 chưa clone repository, có thể apply trực tiếp từ raw GitHub URL sau khi file đã được push:

```bash
kubectl apply -f https://raw.githubusercontent.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2/main/cloud/w9/day-a/exercises/d1-gitops-cicd/argocd/apps/demo-app.yaml
```

Hoàn thành khi Application `demo-app` ở trạng thái:

```text
Synced
Healthy
```

---

# Lab 3 - Sync và Self-Heal

## Phần A: Thay đổi qua Git

Trên local, sửa:

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/manifests/demo-app.yaml
```

Đổi:

```yaml
replicas: 2
```

thành:

```yaml
replicas: 3
```

Commit và push:

```bash
git add cloud/w9/day-a/exercises/d1-gitops-cicd/manifests/demo-app.yaml
git commit -m "[W9-D1] Scale demo app through GitOps"
git push origin main
```

Trong EC2:

```bash
kubectl get deployment demo-app -w
kubectl get pods -l app=demo-app
```

ArgoCD sẽ tự đồng bộ Deployment lên 3 replicas.

## Phần B: Kiểm tra Self-Heal

Trong EC2, cố tình sửa cluster bằng tay:

```bash
kubectl scale deployment/demo-app --replicas=5
kubectl get deployment demo-app -w
```

Vì Git vẫn khai báo 3 replicas và `selfHeal: true`, ArgoCD sẽ đưa Deployment quay lại 3 replicas.

---

# Lab 4 - Rollback bằng Git Revert

Trên local:

```bash
git revert HEAD --no-edit
git push origin main
```

Trong EC2:

```bash
kubectl get deployment demo-app -w
```

ArgoCD đọc commit revert và đưa cluster về desired state cũ.

Không ưu tiên:

```bash
kubectl rollout undo deployment/demo-app
```

Lệnh trên chỉ đổi cluster. Git vẫn giữ trạng thái mới nên ArgoCD có thể self-heal và apply lại trạng thái trong Git.

---

# Lab 5 - App of Apps

## File cần hiểu

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/argocd/app-of-apps.yaml
```

Root Application theo dõi:

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/argocd/apps
```

Mọi ArgoCD Application con đặt trong thư mục này sẽ được root quản lý.

## Trong EC2

Apply root Application bằng tay một lần:

```bash
kubectl apply -f https://raw.githubusercontent.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2/main/cloud/w9/day-a/exercises/d1-gitops-cicd/argocd/app-of-apps.yaml
kubectl get applications -n argocd
```

Hoàn thành khi thấy:

```text
w9-root
demo-app
```

Sau bước này, thêm Application mới bằng cách thêm YAML vào `argocd/apps` rồi push Git. Không cần apply từng child Application bằng tay nữa.

---

# Lab 6 - Sync Waves

Manifest demo app hiện có:

```text
Service wave 0
Deployment wave 10
```

Kiểm tra tại:

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/manifests/demo-app.yaml
```

Ý nghĩa:

- Wave nhỏ chạy trước.
- Service được tạo trước.
- Deployment được tạo sau.

Để luyện đầy đủ giống tài liệu HTML, có thể bổ sung:

```text
Namespace wave -1
ConfigMap wave 0
Deployment wave 1
Service wave 2
```

Quan sát thứ tự sync trên ArgoCD UI.

---

# Lab 7 - CI Validation

Workflow Terraform hiện có:

```text
.github/workflows/w9-terraform-ci.yml
```

Workflow này kiểm tra Terraform W8 bằng:

```text
fmt -> init -> validate -> plan
```

Tài liệu HTML sử dụng `kubeconform` để validate Kubernetes YAML trên pull request. Đây là workflow khác và cần bổ sung nếu muốn hoàn thành đúng toàn bộ Lab 7.

Sau khi workflow validation tồn tại:

1. Bật branch protection cho `main`.
2. Yêu cầu pull request trước khi merge.
3. Yêu cầu validation workflow pass.

---

# Checklist hoàn thành buổi sáng

- [ ] Kind cluster W8 chạy trên EC2.
- [ ] Truy cập EC2 bằng Session Manager.
- [ ] ArgoCD đã được cài.
- [ ] Child Application `demo-app` Synced và Healthy.
- [ ] Đổi replicas qua Git và ArgoCD tự sync.
- [ ] Sửa replicas bằng `kubectl scale` và ArgoCD self-heal.
- [ ] Rollback bằng `git revert`.
- [ ] Root Application quản lý child Application.
- [ ] Quan sát được sync waves.
- [ ] GitHub Actions validation chạy trên pull request.

## Tài liệu liên quan trong repository

- `cloud/w9/day-a/README.md`
- `cloud/w9/day-a/theory/`
- `cloud/w9/day-a/exercises/d1-gitops-cicd/README.md`
- `cloud/w9/day-a/exercises/d1-gitops-cicd/demo-app-yaml-explained.md`
- `cloud/w9/day-a/exercises/d1-gitops-cicd/cicd-workflow-explained.md`
- `cloud/w9/END-TO-END-LAB-STEPS.md`
