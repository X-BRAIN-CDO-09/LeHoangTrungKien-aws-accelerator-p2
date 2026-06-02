# 05 - NetworkPolicy Exercise

## Đề Bài

Trong `manifests/`, tự viết:

- Một Pod `frontend` label `app: frontend`.
- Một Pod `backend` label `app: backend`.
- Một NetworkPolicy áp dụng cho `backend`.
- Chỉ cho phép ingress vào `backend` từ Pod có label `app: frontend`.

## Chạy Thử

```bash
kubectl apply -f manifests/
kubectl get networkpolicy
kubectl describe networkpolicy <policy-name>
```

Nếu CNI hỗ trợ policy, kiểm tra kết nối giữa Pod bằng `kubectl exec`.

## Câu Hỏi Tự Kiểm Tra

1. NetworkPolicy chọn Pod bằng field nào?
2. Ingress khác egress ở điểm nào?
3. Vì sao policy có thể apply được nhưng không enforce trong một số cluster?

