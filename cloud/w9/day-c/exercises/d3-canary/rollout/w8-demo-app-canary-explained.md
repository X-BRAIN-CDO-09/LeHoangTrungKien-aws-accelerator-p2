# Giải thích YAML Canary cho Demo App W8

File thực hành:

```text
rollout/w8-demo-app-canary.yaml
```

## Mục tiêu của file

File YAML chuyển demo app của W8 từ `Deployment` thông thường sang `Rollout` của Argo Rollouts.

Ứng dụng vẫn sử dụng:

- Image: `docker.io/kienlht/k8s-demo-app:v1`.
- Container port: `80`.
- NodePort: `30080`.
- Label: `app: demo-app`.

Điểm mới là phiên bản sau không thay thế toàn bộ pod ngay lập tức. Rollout tạo canary theo từng mức `20%`, `40%`, `60%`, `80%`, sau đó mới promote toàn bộ.

## Tài nguyên thứ nhất: Service

```yaml
apiVersion: v1
kind: Service
```

Đây là Kubernetes Service dùng để cung cấp một địa chỉ truy cập ổn định cho các pod. Pod cũ hoặc pod canary có thể thay đổi, nhưng Service vẫn giữ nguyên.

```yaml
metadata:
  name: demo-app
  namespace: default
```

Service giữ tên và namespace giống demo app W8 để tiếp tục sử dụng luồng truy cập cũ.

```yaml
spec:
  type: NodePort
```

`NodePort` mở một cổng trên Kubernetes node. W8 đã cấu hình Kind và EC2 để truy cập ứng dụng qua port này.

```yaml
selector:
  app: demo-app
```

Service gửi traffic đến mọi pod có label `app: demo-app`. Cả stable pod và canary pod đều dùng label này.

```yaml
ports:
  - port: 80
    targetPort: http
    nodePort: 30080
```

- `port: 80`: cổng của Service bên trong cluster.
- `targetPort: http`: gửi traffic đến container port có tên `http`.
- `nodePort: 30080`: giữ nguyên cổng public đã dùng trong W8.

## Tài nguyên thứ hai: Rollout

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
```

`Rollout` là Custom Resource của Argo Rollouts. Kubernetes mặc định không hiểu loại tài nguyên này nếu chưa cài Argo Rollouts controller và CRD.

```yaml
replicas: 5
```

Rollout duy trì tổng cộng 5 replicas. Chọn 5 pod giúp mỗi pod tương ứng khoảng 20%, phù hợp với các bước canary:

```text
1 pod = 20%
2 pod = 40%
3 pod = 60%
4 pod = 80%
5 pod = 100%
```

Nếu chỉ dùng 3 replicas, Kubernetes không thể chia chính xác mức 20%.

```yaml
revisionHistoryLimit: 3
```

Giữ lại tối đa 3 ReplicaSet cũ để hỗ trợ xem lịch sử và rollback.

```yaml
minReadySeconds: 10
progressDeadlineSeconds: 600
```

- Pod phải Ready ổn định ít nhất 10 giây trước khi được xem là available.
- Rollout có tối đa 600 giây để tiến triển trước khi bị xem là gặp vấn đề.

## Selector và Pod labels

```yaml
selector:
  matchLabels:
    app: demo-app
```

Rollout quản lý các pod có label `app: demo-app`.

```yaml
template:
  metadata:
    labels:
      app: demo-app
```

Mọi pod được Rollout tạo ra đều mang label này. Label phải khớp với selector của Rollout và Service.

## Container của Demo App W8

```yaml
image: docker.io/kienlht/k8s-demo-app:v1
```

Đây là image đã build từ thư mục:

```text
cloud/w8/lab/demo-app/
```

Dockerfile sử dụng nginx và copy `index.html`, `styles.css` vào thư mục phục vụ web.

```yaml
ports:
  - name: http
    containerPort: 80
```

Container nginx lắng nghe port `80`. Đặt tên port là `http` giúp Service và probes tham chiếu dễ đọc hơn.

## Readiness và Liveness Probe

```yaml
readinessProbe:
  httpGet:
    path: /
    port: http
```

Readiness probe kiểm tra pod đã sẵn sàng nhận traffic chưa. Nếu probe thất bại, Service tạm thời không gửi request đến pod đó.

```yaml
livenessProbe:
  httpGet:
    path: /
    port: http
```

Liveness probe kiểm tra container còn hoạt động không. Nếu probe thất bại liên tục, Kubernetes restart container.

Readiness bảo vệ traffic. Liveness hỗ trợ phục hồi container bị treo.

## Resources

```yaml
resources:
  requests:
    cpu: 25m
    memory: 32Mi
  limits:
    cpu: 100m
    memory: 128Mi
```

- `requests`: lượng tài nguyên tối thiểu scheduler dùng khi chọn node.
- `limits`: mức tối đa container được phép sử dụng.

## Chiến lược Canary

```yaml
maxSurge: 1
maxUnavailable: 0
```

- `maxSurge: 1`: cho phép tạo thêm tối đa một pod trong quá trình rollout.
- `maxUnavailable: 0`: không chủ động làm giảm số pod available trong lúc cập nhật.

## Các bước Rollout

```yaml
- setWeight: 20
- pause: {}
```

Argo Rollouts tạo khoảng 20% canary pods rồi dừng vô thời hạn. Cần kiểm tra ứng dụng và chạy lệnh promote để đi tiếp.

```bash
kubectl argo rollouts promote demo-app
```

```yaml
- setWeight: 40
- pause:
    duration: 60s
```

Canary tăng lên 40%, chờ 60 giây rồi tự đi tiếp.

Các bước 60% và 80% hoạt động tương tự. Tại 80%, Rollout dừng lần nữa để kiểm tra cuối trước khi promote toàn bộ.

## Luồng hoạt động hoàn chỉnh

```text
Sửa image v1 thành v2
        |
        v
Apply hoặc ArgoCD sync Rollout
        |
        v
Argo Rollouts tạo ReplicaSet v2
        |
        v
20% v2 + 80% v1
        |
        v
Kiểm tra ứng dụng và promote
        |
        v
40% -> 60% -> 80%
        |
        v
Promote lần cuối
        |
        v
100% v2, ReplicaSet v1 được giữ trong history
```

Không có traffic router nên `setWeight` được thực hiện bằng cách điều chỉnh số lượng pod. Service phân phối traffic giữa các pod stable và canary đang Ready.

## Chuẩn bị trước khi apply

W8 hiện đã tạo `Deployment/demo-app` và `Service/demo-app` trong namespace `default`. Không được để Deployment cũ và Rollout mới cùng quản lý label `app: demo-app`.

Xóa Deployment cũ nhưng giữ Service:

```bash
kubectl delete deployment demo-app
```

File YAML sẽ cập nhật lại Service và tạo Rollout mới.

Argo Rollouts controller phải được cài trước:

```bash
kubectl get crd rollouts.argoproj.io
kubectl get pods -n argo-rollouts
```

## Apply và kiểm tra

```bash
kubectl apply -f rollout/w8-demo-app-canary.yaml
kubectl argo rollouts get rollout demo-app --watch
```

Kiểm tra tài nguyên:

```bash
kubectl get rollout,rs,pods,svc
kubectl describe rollout demo-app
curl http://localhost:30080
```

Trên EC2 W8, có thể dùng ALB URL hoặc địa chỉ truy cập đã tạo từ Terraform thay cho `localhost`.

## Tạo phiên bản v2 để luyện Canary

Sửa giao diện trong `cloud/w8/lab/demo-app/`, sau đó build và push tag mới:

```bash
docker build -t docker.io/kienlht/k8s-demo-app:v2 cloud/w8/lab/demo-app
docker push docker.io/kienlht/k8s-demo-app:v2
```

Đổi image trong YAML:

```yaml
image: docker.io/kienlht/k8s-demo-app:v2
```

Apply lại:

```bash
kubectl apply -f rollout/w8-demo-app-canary.yaml
kubectl argo rollouts get rollout demo-app --watch
```

## Các thao tác cần luyện

```bash
kubectl argo rollouts promote demo-app
kubectl argo rollouts abort demo-app
kubectl argo rollouts retry rollout demo-app
kubectl argo rollouts undo demo-app
```

- `promote`: tiếp tục rollout sau bước pause.
- `abort`: dừng canary và quay traffic về stable version.
- `retry`: thử lại rollout đã bị abort/error.
- `undo`: quay về revision trước.

## Giới hạn hiện tại

Demo app W8 là static nginx và chưa phát metric `http_requests_total`. Vì vậy file này sử dụng manual pause để kiểm tra trước khi promote.

Muốn auto-abort dựa trên success rate hoặc burn rate, cần instrument ứng dụng hoặc thu thập nginx metrics, sau đó gắn AnalysisTemplate vào các bước canary.
