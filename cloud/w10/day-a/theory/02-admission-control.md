# Admission Control

Admission control là lớp kiểm tra resource sau khi request đã qua authentication và authorization nhưng trước khi object được lưu vào etcd.

## Tại sao cần admission policy

RBAC trả lời câu hỏi "ai được tạo workload". Admission policy trả lời câu hỏi "workload đó có đúng chuẩn an toàn không".

Ví dụ:

- developer có quyền tạo Pod
- nhưng Pod có `privileged: true`
- admission policy sẽ chặn ngay tại cluster

## Luồng xử lý

```text
kubectl apply
-> authn
-> authz / RBAC
-> admission controllers
-> etcd
```

## Policy nên có trong W10

- Bắt buộc `runAsNonRoot`.
- Không cho `latest` tag.
- Bắt buộc requests/limits.
- Cấm `privileged` container.
