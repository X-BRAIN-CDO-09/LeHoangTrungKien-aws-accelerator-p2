# 04 - ConfigMap And Secret Exercise

## Đề Bài

Trong `manifests/`, tự viết:

- Một ConfigMap tên `app-config` có key `APP_ENV`.
- Một Secret tên `app-secret` có key `API_TOKEN`.
- Một Pod đọc `APP_ENV` và `API_TOKEN` qua environment variables.

## Chạy Thử

```bash
kubectl apply -f manifests/
kubectl get configmap
kubectl get secret
kubectl describe pod <pod-name>
```

## Câu Hỏi Tự Kiểm Tra

1. ConfigMap khác Secret ở điểm nào?
2. Secret có phải là mã hóa mạnh mặc định không?
3. Vì sao không nên hardcode secret vào Docker image?

