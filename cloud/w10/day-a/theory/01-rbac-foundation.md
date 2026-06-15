# RBAC Foundation

RBAC giúp tách "ai được làm gì" ra khỏi ứng dụng. Trong W10, RBAC là lớp chặn đầu tiên trước khi đi tới policy engine.

## Thành phần chính

- `ServiceAccount`: danh tính của workload trong cluster.
- `Role`: quyền trong một namespace.
- `ClusterRole`: quyền ở toàn cluster hoặc tập resource cluster-scoped.
- `RoleBinding`: gắn `Role` hoặc `ClusterRole` vào user/group/serviceaccount trong một namespace.
- `ClusterRoleBinding`: gắn quyền ở mức cluster.

## Mẫu role để học

- `developer`: deploy workload trong namespace team, không sửa RBAC, không đọc secret.
- `sre`: có quyền debug workload, đọc logs, rollout, xác nhận policy.
- `viewer`: chỉ đọc resource.

## Lệnh cần nhớ

```bash
kubectl auth can-i get pods --as system:serviceaccount:team-a:developer -n team-a
kubectl auth can-i list secrets --as system:serviceaccount:team-a:developer -n team-a
kubectl auth can-i patch deployments --as system:serviceaccount:team-a:sre -n team-a
```

## Ghi nhớ

- Bắt đầu bằng least privilege.
- Không gắn `cluster-admin` cho team app.
- Dùng `Role` trong namespace trước, chỉ lên `ClusterRole` nếu thật sự cần.
