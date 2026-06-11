# Giải thích Demo App YAML của Day A

## Mục đích

File `manifests/demo-app.yaml` chuyển cách quản lý demo app W8 từ:

```text
EC2 user data -> kubectl apply /tmp/demo-app.yaml
```

sang:

```text
Git -> ArgoCD -> Kubernetes
```

Ứng dụng vẫn sử dụng đúng image W8:

```text
docker.io/kienlht/k8s-demo-app:v1
```

Service vẫn dùng `NodePort 30080`, vì ALB và kind cluster W8 đã được cấu hình để chuyển traffic qua port này.

## Luồng hoạt động tổng thể

```text
Git repository
    |
    | ArgoCD đọc thư mục manifests
    v
Deployment demo-app
    |
    | tạo và duy trì 2 Pods
    v
Pods chạy image docker.io/kienlht/k8s-demo-app:v1
    ^
    | Service chọn Pod bằng label app=demo-app
    |
Service demo-app: NodePort 30080
    ^
    | ALB forward traffic vào EC2:30080
    |
Người dùng
```

## Phần Deployment ghi gì?

### apiVersion và kind

```yaml
apiVersion: apps/v1
kind: Deployment
```

Hai trường này yêu cầu Kubernetes tạo một Deployment. Deployment chịu trách nhiệm duy trì số lượng Pod và thực hiện rolling update khi image hoặc Pod template thay đổi.

### metadata

```yaml
metadata:
  name: demo-app
  namespace: default
  labels:
    app: demo-app
```

- `name`: tên Deployment.
- `namespace`: giữ nguyên namespace của app W8 để ArgoCD quản lý đúng resource đang tồn tại.
- `labels`: metadata giúp tìm kiếm và tổ chức resource.

Annotation sync wave:

```yaml
argocd.argoproj.io/sync-wave: "10"
```

Deployment được đặt ở wave 10, sau Service ở wave 0. Sync wave thể hiện thứ tự ArgoCD apply tài nguyên.

### replicas và revision history

```yaml
replicas: 2
revisionHistoryLimit: 3
```

- Kubernetes cần duy trì 2 Pod demo app.
- Giữ tối đa 3 ReplicaSet cũ để hỗ trợ kiểm tra lịch sử và rollback.

### selector và Pod labels

```yaml
selector:
  matchLabels:
    app: demo-app
template:
  metadata:
    labels:
      app: demo-app
```

Deployment chỉ quản lý các Pod có label `app: demo-app`. Giá trị trong selector phải khớp với label trong Pod template.

### container image

```yaml
containers:
  - name: demo-app
    image: docker.io/kienlht/k8s-demo-app:v1
```

Mỗi Pod chạy một container từ public Docker Hub image đã build trong W8. Vì image public nên Kubernetes không cần `imagePullSecret`.

### container port

```yaml
ports:
  - name: http
    containerPort: 80
```

Container nginx lắng nghe HTTP tại port 80. Tên `http` được Service và probes sử dụng thay vì lặp lại số port.

### readiness probe

```yaml
readinessProbe:
  httpGet:
    path: /
    port: http
```

Readiness probe kiểm tra Pod đã sẵn sàng nhận traffic chưa. Nếu kiểm tra thất bại, Pod vẫn chạy nhưng Service tạm thời không chuyển request đến Pod đó.

### liveness probe

```yaml
livenessProbe:
  httpGet:
    path: /
    port: http
```

Liveness probe kiểm tra container còn hoạt động bình thường không. Nếu kiểm tra thất bại nhiều lần, Kubernetes restart container.

### resources

```yaml
resources:
  requests:
    cpu: 25m
    memory: 32Mi
  limits:
    cpu: 100m
    memory: 128Mi
```

- `requests`: lượng tài nguyên scheduler dùng để chọn node cho Pod.
- `limits`: mức tối đa container được phép sử dụng.

## Phần Service ghi gì?

### Service type

```yaml
kind: Service
spec:
  type: NodePort
```

Service cung cấp một endpoint ổn định cho các Pod. `NodePort` mở port trên Kubernetes node để traffic bên ngoài cluster có thể truy cập.

### selector

```yaml
selector:
  app: demo-app
```

Service tìm các Pod có label `app: demo-app` và chuyển request đến những Pod đó. Đây là lý do label của Deployment, Pod và selector phải đồng nhất.

### port mapping

```yaml
ports:
  - name: http
    port: 80
    targetPort: http
    nodePort: 30080
```

- `nodePort: 30080`: port được mở trên kind node và EC2 host.
- `port: 80`: port nội bộ của Service.
- `targetPort: http`: chuyển request đến named container port `http`, tương ứng port 80.

Luồng port:

```text
ALB -> EC2:30080 -> kind node:30080 -> Service:80 -> Pod:80
```

## ArgoCD thực hiện gì?

Child Application `argocd/apps/demo-app.yaml` trỏ đến thư mục:

```text
cloud/w9/day-a/exercises/d1-gitops-cicd/manifests
```

Khi sync, ArgoCD:

1. Đọc file `demo-app.yaml` từ Git.
2. So sánh với Deployment và Service đang chạy trong cluster.
3. Apply các điểm khác biệt.
4. Tiếp tục theo dõi để phát hiện drift.
5. Tự sửa drift vì `selfHeal: true`.
6. Xóa resource đã bị xóa khỏi Git vì `prune: true`.

Do tên resource và namespace giữ nguyên như W8, ArgoCD sẽ quản lý Deployment và Service hiện tại thay vì tạo một bộ resource mới.

## Điều gì xảy ra khi đổi image?

Nếu sửa:

```yaml
image: docker.io/kienlht/k8s-demo-app:v2
```

rồi commit và push:

1. ArgoCD phát hiện Git thay đổi.
2. ArgoCD cập nhật Pod template của Deployment.
3. Deployment tạo ReplicaSet mới.
4. Pod mới pull image `v2`.
5. Readiness probe phải thành công trước khi Pod nhận traffic.
6. Pod cũ được giảm dần theo rolling update.

## Các lệnh luyện tập

```bash
kubectl get deployment,service,pods
kubectl describe deployment demo-app
kubectl get endpoints demo-app
kubectl rollout status deployment/demo-app --timeout=180s
kubectl get deployment demo-app -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Kiểm tra ArgoCD:

```bash
kubectl get applications -n argocd
argocd app get demo-app
argocd app sync demo-app
```

## Điểm cần nhớ

- Deployment quản lý Pod và quá trình cập nhật phiên bản.
- Service cung cấp địa chỉ ổn định và route traffic đến Pod.
- Labels và selectors kết nối Deployment, Pod và Service.
- Probes quyết định khi nào Pod nhận traffic hoặc cần restart.
- ArgoCD biến YAML trong Git thành desired state và liên tục giữ cluster khớp với desired state đó.
