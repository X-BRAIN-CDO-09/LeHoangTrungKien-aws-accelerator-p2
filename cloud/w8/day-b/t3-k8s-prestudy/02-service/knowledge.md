# 02 - Service Knowledge

## Service Là Gì?

Service tạo một network endpoint ổn định để truy cập Pod. Pod có thể bị xóa và tạo lại với IP mới, nhưng Service giữ tên và virtual IP ổn định.

Khi Service được tạo, Kubernetes không route traffic theo Pod name. Service dùng selector để tìm Pod có label phù hợp, rồi tạo endpoint trỏ tới IP/port của các Pod đó.

## Vì Sao Cần Service?

Nếu gọi trực tiếp Pod IP, ứng dụng dễ hỏng khi Pod restart. Service chọn Pod bằng label selector và route traffic tới các Pod phù hợp.

Ví dụ app backend có 3 Pod. Nếu một Pod chết và được tạo lại, IP của Pod mới có thể khác. Client vẫn gọi Service như cũ, còn Service tự cập nhật endpoint phía sau.

## Loại Service Cơ Bản

- `ClusterIP`: chỉ truy cập trong cluster.
- `NodePort`: mở port trên node để truy cập từ ngoài cluster.
- `LoadBalancer`: dùng cloud load balancer nếu chạy trên cloud.

Trong minikube, thường bắt đầu với `ClusterIP` hoặc `NodePort`.

## Selector

Service tìm Pod bằng selector:

```yaml
selector:
  app: demo-nginx
```

Pod phải có label khớp:

```yaml
labels:
  app: demo-nginx
```

Nếu selector không khớp label của Pod, Service sẽ không có endpoint. Khi đó lệnh như `minikube service hello-minikube` có thể báo:

```text
service not available: no running pod for service hello-minikube found
```

Đây không nhất thiết là Service hỏng. Nó thường có nghĩa là Service không tìm thấy Pod nào đang Running và khớp selector.

## Endpoint Là Gì?

Endpoint là danh sách IP/port thật mà Service sẽ route tới.

Kiểm tra endpoint:

```bash
kubectl get endpoints <service-name>
```

Nếu endpoint rỗng, kiểm tra:

- Pod có Running không?
- Label của Pod có khớp selector của Service không?
- Container port/targetPort có đúng không?

## `port`, `targetPort`, `nodePort`

- `port`: port của Service bên trong cluster.
- `targetPort`: port trên container/Pod mà Service forward tới.
- `nodePort`: port mở trên node khi Service type là `NodePort`.

Ví dụ:

```yaml
ports:
  - port: 80
    targetPort: 8080
```

Client gọi Service port `80`, Service forward vào container port `8080`.

## Lệnh Hay Dùng

```bash
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
kubectl port-forward svc/<service-name> 8080:80
```

Debug Service selector:

```bash
kubectl get svc <service-name> -o yaml
kubectl get pods --show-labels
```
