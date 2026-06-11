# Troubleshooting Commands - minikube And kubectl

File này lưu các lệnh kiểm tra nhanh khi chạy minikube/kubectl trong T3.

## 1. Kiểm Tra Cluster

```powershell
minikube status
kubectl get nodes
kubectl get pods -A
```

Nếu cluster chưa chạy:

```powershell
minikube start --driver=docker
```

## 2. Kiểm Tra Deployment, Pod, Service

```powershell
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get svc hello-minikube
```

Kiểm tra Pod theo label:

```powershell
kubectl get pods -l app=hello-minikube
```

## 3. Kiểm Tra Service Không Trỏ Tới Pod

Khi gặp lỗi:

```text
SVC_UNREACHABLE: service not available: no running pod for service hello-minikube found
```

chạy:

```powershell
kubectl get pods
kubectl get svc hello-minikube -o yaml
kubectl describe svc hello-minikube
kubectl get endpoints hello-minikube
```

Ý nghĩa:

- `kubectl get pods`: xem Pod có Running không.
- `kubectl get svc ... -o yaml`: xem selector của Service.
- `kubectl describe svc`: xem Service đang chọn Pod nào và endpoint nào.
- `kubectl get endpoints`: nếu endpoint rỗng, Service chưa tìm thấy Pod phù hợp.

## 4. Xem Lỗi Của Pod

Nếu Pod không Running:

```powershell
kubectl describe pod -l app=hello-minikube
kubectl logs -l app=hello-minikube
```

Các lỗi thường gặp:

- `ImagePullBackOff`: image sai hoặc pull image thất bại.
- `CrashLoopBackOff`: container chạy rồi crash liên tục.
- `Pending`: chưa schedule được Pod.
- `ContainerCreating`: đang tạo container hoặc pull image.

## 5. Tạo Lại hello-minikube Từ Đầu

Nếu Service có nhưng không có Pod Running, tạo lại:

```powershell
kubectl delete svc hello-minikube
kubectl delete deployment hello-minikube

kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```

Chờ Pod Running:

```powershell
kubectl get pods -w
```

Khi Pod đã Running:

```powershell
minikube service hello-minikube
```

## 6. Dùng Port Forward Thay Cho minikube service

Nếu `minikube service` không mở được browser hoặc gặp lỗi network, thử:

```powershell
kubectl port-forward service/hello-minikube 7080:8080
```

Sau đó mở:

```text
http://localhost:7080
```

## 7. Xem Log minikube

Nếu minikube lỗi sâu hơn:

```powershell
minikube logs
```

Ghi log ra file:

```powershell
minikube logs --file=logs.txt
```

## 8. Note Terraform For Expression

Phần này không thuộc Kubernetes, nhưng lưu lại để tra nhanh khi làm bài Terraform `05-for-expression`.

Công thức tạo map bằng `for` expression:

```hcl
{
  for item in list : key => value
}
```

Dấu `:` nghĩa là sau đây là cách biến từng item thành kết quả. Dấu `=>` nghĩa là bên trái là key của map, bên phải là value của map.

Ví dụ:

```hcl
services = ["api", "worker", "web"]
```

Nếu muốn map service gốc sang service name đầy đủ:

```hcl
service_map = {
  for service in var.services : service => "${local.name_prefix}-${service}"
}
```

Kết quả:

```hcl
{
  api    = "xbrain-dev-api"
  worker = "xbrain-dev-worker"
  web    = "xbrain-dev-web"
}
```

Dạng `k, v` với list:

```hcl
{
  for k, v in var.services : v => "${local.name_prefix}-${v}"
}
```

Với list, `k` là index và `v` là value:

```text
k = 0, v = "api"
k = 1, v = "worker"
k = 2, v = "web"
```

Nếu viết:

```hcl
{
  for k, v in var.services : k => "${local.name_prefix}-${v}"
}
```

thì key sẽ là index:

```hcl
{
  0 = "xbrain-dev-api"
  1 = "xbrain-dev-worker"
  2 = "xbrain-dev-web"
}
```

Trong bài `service_map`, nên dùng service name làm key, nên cách dễ đọc nhất là:

```hcl
service_map = {
  for service in var.services : service => "${local.name_prefix}-${service}"
}
```
