# 01 - Pod Exercise

## Đề Bài

Trong `manifests/`, tự viết một manifest Pod:

- Tên Pod: `demo-nginx`.
- Image: `nginx:1.27`.
- Label: `app: demo-nginx`.
- Container port: `80`.

## Chạy Thử

```bash
kubectl apply -f manifests/
kubectl get pods
kubectl describe pod demo-nginx
kubectl logs demo-nginx
```

## Câu Hỏi Tự Kiểm Tra

1. Pod khác container ở điểm nào?
2. Vì sao Pod cần label?
3. Nếu image sai tên thì Pod sẽ rơi vào trạng thái gì?

