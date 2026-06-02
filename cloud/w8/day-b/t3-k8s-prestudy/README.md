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
