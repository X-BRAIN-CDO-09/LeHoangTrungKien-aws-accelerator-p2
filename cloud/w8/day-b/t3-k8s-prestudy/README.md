# T3 02/06 - Kubernetes Pre-study

Mục tiêu của T3 là đọc trước kiến thức nền Kubernetes trước buổi onsite T5. Không cần làm lab lớn ngay, nhưng cần hiểu object cơ bản và chuẩn bị môi trường local.

## Thứ Tự Học

1. `install-checklist.md`: kiểm tra Docker, kubectl, minikube.
2. `troubleshooting-commands.md`: các lệnh kiểm tra khi minikube/service/pod lỗi.
3. `01-pod`: Pod là đơn vị chạy container nhỏ nhất trong Kubernetes.
4. `02-service`: Service tạo network endpoint ổn định cho Pod.
5. `03-probes`: probes giúp Kubernetes biết container còn sống và đã sẵn sàng chưa.
6. `04-configmap-secret`: tách config và secret ra khỏi image/container.
7. `05-networkpolicy`: kiểm soát traffic giữa Pod.

## Lệnh Kiểm Tra Cơ Bản

```bash
docker --version
kubectl version --client
minikube version
minikube status
```

Nếu chưa có cluster:

```bash
minikube start
kubectl get nodes
```

## Cách Làm Exercise

Mỗi topic có:

- `knowledge.md`: kiến thức nền cần đọc.
- `exercise.md`: đề bài thực hành.
- `manifests/`: nơi tự viết YAML.

Không copy đáp án trước. Tự viết manifest, chạy thử, rồi ghi lại lỗi hoặc câu hỏi.

## Mental Model Ngắn

Kubernetes không chỉ chạy container đơn lẻ. Nó quản lý nhiều object phối hợp với nhau:

- Pod chạy container.
- Service tìm Pod bằng label selector và tạo endpoint ổn định.
- Probes giúp Kubernetes biết Pod có nên nhận traffic hoặc restart không.
- ConfigMap/Secret đưa cấu hình vào Pod mà không bake vào image.
- NetworkPolicy giới hạn traffic giữa các Pod.

Khi gặp lỗi, luôn kiểm tra theo thứ tự: cluster có chạy không, Pod có Running không, Service selector có khớp label Pod không, endpoint của Service có rỗng không, rồi mới xem log chi tiết.

## Tổng Hợp Thành Phần Kubernetes

### 1. Control Plane Và Worker Node

- `Control Plane` là phần điều khiển cluster: nhận YAML, lưu desired state, quyết định Pod sẽ chạy ở đâu.
- `Worker Node` là máy thực sự chạy Pod.
- `kubelet` trên mỗi node chịu trách nhiệm nhận lệnh từ control plane và tạo container thông qua container runtime.

Mental model:

- Control plane giống "bộ não".
- Worker node giống "máy chủ chạy app".

### 2. Pod

- Pod là đơn vị chạy nhỏ nhất trong Kubernetes.
- Một Pod thường chứa một container ứng dụng.
- Pod có IP riêng, nhưng IP này không bền vững, vì Pod có thể bị xóa và tạo lại.

Pod phù hợp để hiểu:

- App đang chạy image gì.
- App nghe ở port nào.
- App có env/config/secret gì.
- App đang `Running`, `CrashLoopBackOff` hay `ImagePullBackOff`.

### 3. Deployment

- Deployment không trực tiếp chạy app, mà quản lý số lượng Pod mong muốn.
- Nếu Pod chết, Deployment tạo Pod mới.
- Nếu update image, Deployment rollout dần Pod mới thay cho Pod cũ.

Chuỗi tạo object hay gặp:

`Deployment -> ReplicaSet -> Pod`

### 4. Service

- Service tạo địa chỉ ổn định để gọi Pod.
- Service tìm Pod bằng `label selector`.
- Pod đổi IP vẫn không sao, vì Service cập nhật endpoint phía sau.

Ba loại hay gặp:

- `ClusterIP`: chỉ dùng trong cluster.
- `NodePort`: mở cổng trên node để truy cập từ ngoài.
- `LoadBalancer`: dùng load balancer của cloud.

### 5. Probes

- `startupProbe`: app khởi động xong chưa.
- `readinessProbe`: app đã sẵn sàng nhận request chưa.
- `livenessProbe`: app còn sống ổn không, hay cần restart.

Ý nghĩa thực tế:

- Readiness fail: Pod vẫn chạy nhưng chưa nhận traffic.
- Liveness fail: container bị restart.

### 6. ConfigMap Và Secret

- `ConfigMap` chứa config không nhạy cảm.
- `Secret` chứa dữ liệu nhạy cảm hơn như password, token, API key.

Nguyên tắc quan trọng:

- Không hardcode config vào code nếu cần thay đổi theo môi trường.
- Không bake secret vào image.

### 7. NetworkPolicy

- NetworkPolicy kiểm soát Pod nào được nói chuyện với Pod nào.
- Dùng `podSelector` và rule `ingress`/`egress`.
- Nếu không có policy, nhiều cluster mặc định cho traffic nội bộ khá thoáng.

## Luồng Hoạt Động Của Ứng Dụng Trong Kubernetes

Một luồng cơ bản từ lúc deploy đến lúc nhận request:

1. Dev viết manifest `Deployment`, `Service`, `ConfigMap`, `Secret`.
2. `kubectl apply` gửi desired state lên API server của cluster.
3. Control plane lưu desired state và scheduler chọn node phù hợp.
4. `kubelet` trên node kéo image và chạy container bên trong Pod.
5. Pod khởi động ứng dụng, nạp env/config từ ConfigMap hoặc Secret.
6. `startupProbe` và `readinessProbe` kiểm tra app đã khởi động và sẵn sàng chưa.
7. Khi Pod ready, Service thêm Pod đó vào endpoint list.
8. Client gọi Service, rồi Service route request đến một Pod healthy phía sau.
9. Nếu app treo hoặc health check fail, `livenessProbe` có thể khiến container bị restart.
10. Nếu Pod chết hẳn, Deployment tạo Pod mới để giữ đủ số replica mong muốn.

Luồng request ngắn gọn có thể nhớ như sau:

`Client -> LoadBalancer/NodePort -> Service -> Pod -> Container`

Nếu ứng dụng có nhiều tầng:

`User -> frontend Service -> frontend Pod -> backend Service -> backend Pod -> database`

## Mapping Kubernetes Với AWS

Kubernetes và AWS không phải lúc nào cũng có object 1-1 tuyệt đối, nhưng có thể liên hệ như sau để dễ hình dung:

| Kubernetes | Vai trò | AWS tương ứng gần đúng |
| --- | --- | --- |
| Cluster | Cụm tài nguyên chạy ứng dụng | `EKS cluster` |
| Control Plane | Quản lý trạng thái cluster | Control plane do `Amazon EKS` managed |
| Worker Node | Máy chạy workload | `EC2` trong node group hoặc Fargate |
| Pod | Đơn vị chạy app nhỏ nhất | Gần giống một task/instance chạy app, nhưng nhỏ hơn `EC2`; nếu so sánh AWS-native thì gần với `ECS task` hơn |
| Deployment | Giữ số lượng Pod, rollout version | Gần với `Auto Scaling + deployment controller` |
| Service `ClusterIP` | Endpoint nội bộ ổn định | Gần với service discovery nội bộ như `AWS Cloud Map` |
| Service `LoadBalancer` | Expose app ra ngoài qua LB | `AWS Load Balancer` như `NLB` hoặc tích hợp với `ALB/NLB` |
| Ingress | Rule HTTP/HTTPS routing | Gần với `ALB listener rules` |
| ConfigMap | Cấu hình không nhạy cảm | `SSM Parameter Store` hoặc config file/env ngoài image |
| Secret | Dữ liệu nhạy cảm | `AWS Secrets Manager` hoặc `SSM SecureString` |
| NetworkPolicy | Rule traffic giữa Pod | Ý tưởng gần với `Security Group`/segmentation, nhưng phạm vi ở mức Pod |
| PersistentVolume | Lưu trữ bền vững cho Pod | `EBS` hoặc `EFS` tùy kiểu mount |

Lưu ý khi map:

- `Service` không phải là AWS Load Balancer trong mọi trường hợp. Chỉ `Service type LoadBalancer` mới thường kéo theo LB ở cloud.
- `Pod` không tương đương hoàn toàn với `EC2 instance`, vì một node có thể chạy nhiều Pod.
- `NetworkPolicy` chi tiết hơn ở tầng Kubernetes app-to-app, còn `Security Group` là tầng network của AWS resource.

## Luồng Ứng Dụng Trên EKS So Với AWS Truyền Thống

### Nếu chưa dùng Kubernetes

Một luồng AWS truyền thống có thể là:

`User -> ALB -> EC2/Auto Scaling Group -> app process -> RDS`

Ở đây team tự quản lý:

- số lượng EC2,
- cách deploy version mới,
- health check ở instance level,
- cách gắn config và secret vào app.

### Nếu dùng EKS

Luồng sẽ thường là:

`User -> ALB/NLB -> Service/Ingress -> Pod -> container -> RDS`

Kubernetes lo thêm cho mình:

- lịch chạy Pod trên node nào,
- giữ đủ số replica,
- restart container lỗi,
- chỉ route traffic vào Pod ready,
- rollout/rollback version ứng dụng.

Nói ngắn gọn:

- AWS cung cấp hạ tầng cloud.
- EKS cung cấp Kubernetes managed control plane trên hạ tầng đó.
- Kubernetes chịu trách nhiệm orchestration cho containerized application.

## Cách Nghĩ Khi Debug Trên AWS + Kubernetes

Khi app lỗi trên EKS, có thể tách thành 3 lớp:

1. Hạ tầng AWS có ổn không?
   Ví dụ: node có đủ tài nguyên không, load balancer có target healthy không, security group có mở đúng không.
2. Object Kubernetes có khớp nhau không?
   Ví dụ: Deployment tạo được Pod chưa, Service selector có đúng label không, Pod đã ready chưa.
3. Ứng dụng bên trong container có chạy đúng không?
   Ví dụ: app bind sai port, thiếu env, secret sai, probe path sai.

Checklist ngắn:

- `kubectl get nodes`
- `kubectl get pods -A`
- `kubectl get svc`
- `kubectl get endpoints`
- `kubectl describe pod <pod-name>`
- `kubectl logs <pod-name>`

Nếu hiểu được mapping này thì sang EKS, mình sẽ không nhìn Kubernetes như một hệ thống hoàn toàn mới, mà là lớp orchestration nằm trên hạ tầng AWS quen thuộc.
