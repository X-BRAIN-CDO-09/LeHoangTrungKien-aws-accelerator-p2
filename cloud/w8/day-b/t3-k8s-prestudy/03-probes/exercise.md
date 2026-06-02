# 03 - Probes Exercise

## Đề Bài

Trong `manifests/`, tự viết Pod hoặc Deployment chạy `nginx`.

Thêm:

- `readinessProbe` dùng HTTP GET path `/`.
- `livenessProbe` dùng HTTP GET path `/`.
- Container port `80`.

## Chạy Thử

```bash
kubectl apply -f manifests/
kubectl get pods
kubectl describe pod <pod-name>
```

## Câu Hỏi Tự Kiểm Tra

1. Readiness fail thì Service có gửi traffic vào Pod không?
2. Liveness fail thì Kubernetes làm gì?
3. Vì sao app khởi động chậm nên dùng startupProbe?

