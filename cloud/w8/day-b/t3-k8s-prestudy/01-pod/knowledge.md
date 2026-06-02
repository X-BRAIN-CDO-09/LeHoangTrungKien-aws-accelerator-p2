# 01 - Pod Knowledge

## Pod Là Gì?

Pod là đơn vị nhỏ nhất Kubernetes dùng để chạy workload. Một Pod có thể chứa một hoặc nhiều container, nhưng bài nền tảng nên bắt đầu với một container trong một Pod.

Pod thường không được dùng trực tiếp trong production. Thực tế hay dùng Deployment để quản lý Pod. Tuy vậy, hiểu Pod trước giúp đọc được Deployment, Service, probes và NetworkPolicy.

## Pod, Container, Deployment Khác Nhau Thế Nào?

Container là process được đóng gói bằng image, ví dụ `nginx:1.27` hoặc `kicbase/echo-server:1.0`.

Pod là wrapper Kubernetes đặt quanh một hoặc nhiều container. Các container trong cùng Pod chia sẻ network namespace, nên có thể gọi nhau qua `localhost`.

Deployment là object quản lý số lượng Pod mong muốn. Nếu Pod chết, Deployment tạo Pod mới. Khi chạy lệnh:

```bash
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
```

Kubernetes tạo Deployment, Deployment tạo ReplicaSet, ReplicaSet tạo Pod. Vì vậy khi Service báo không có running Pod, cần kiểm tra cả Deployment lẫn Pod.

## Pod Có Gì Quan Trọng?

- Container image.
- Command/args nếu cần override entrypoint.
- Port container expose.
- Environment variables.
- Volume mount nếu cần file/config.
- Labels để Service hoặc NetworkPolicy chọn Pod.

## Labels

Labels là key-value metadata gắn vào Pod.

Ví dụ:

```yaml
labels:
  app: demo-api
```

Service sẽ dùng selector như `app: demo-api` để tìm đúng Pod.

Nếu label của Pod không khớp selector của Service, Service vẫn tồn tại nhưng không có endpoint. Đây là một lỗi rất thường gặp khi mới học Kubernetes.

## Pod Lifecycle Cơ Bản

Các trạng thái hay gặp:

- `Pending`: Pod đã được tạo nhưng chưa chạy được, có thể do đang chờ schedule hoặc pull image.
- `ContainerCreating`: kubelet đang tạo container.
- `Running`: Pod đã chạy.
- `Succeeded`: Pod chạy xong thành công, thường gặp với Job.
- `Failed`: Pod kết thúc thất bại.
- `CrashLoopBackOff`: container chạy rồi crash lặp lại.
- `ImagePullBackOff`: Kubernetes không pull được image.

Khi Pod không Running, dùng `kubectl describe pod <pod-name>` để xem event. Nếu Pod chạy nhưng app lỗi, dùng `kubectl logs <pod-name>`.

## Lệnh Hay Dùng

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl delete pod <pod-name>
```

Xem Pod theo label:

```bash
kubectl get pods -l app=hello-minikube
```

Theo dõi Pod thay đổi trạng thái:

```bash
kubectl get pods -w
```
