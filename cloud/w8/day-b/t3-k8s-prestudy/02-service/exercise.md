# 02 - Service Exercise

## Đề Bài

Trong `manifests/`, tự viết:

- Một Pod `demo-nginx` có label `app: demo-nginx`.
- Một Service `demo-nginx-svc` loại `ClusterIP`.
- Service port `80`, targetPort `80`.
- Selector trỏ tới `app: demo-nginx`.

## Chạy Thử

```bash
kubectl apply -f manifests/
kubectl get pods
kubectl get svc
kubectl port-forward svc/demo-nginx-svc 8080:80
```

Sau đó mở:

```text
http://localhost:8080
```

## Câu Hỏi Tự Kiểm Tra

1. Vì sao Service không trỏ trực tiếp tới Pod name?
2. Selector của Service phải khớp với gì?
3. `port` khác `targetPort` như thế nào?

