# Payments Tenant

Folder này onboard team `payments` vào platform dùng chung nhưng vẫn cô lập với namespace `demo`.

## Vì sao guardrail cũ tự áp cho team B?

Gatekeeper constraints đã được mở rộng từ namespace `demo` sang cả `payments`. Vì vậy mọi Pod/Deployment/Rollout của team B vẫn bị kiểm tra các luật cũ: không dùng `latest`, phải có limits, không chạy root, không hostNetwork, có owner label và chỉ dùng registry được duyệt.

Sigstore Policy Controller enforce theo label namespace:

```text
policy.sigstore.dev/include=true
```

Namespace `payments` có label này, nên image `w10-api` của team B phải có chữ ký Cosign hợp lệ.

## Vì sao dùng Role/RoleBinding thay vì ClusterRoleBinding?

`Role` và `RoleBinding` bị giới hạn trong namespace `payments`, nên `payments-dev` chỉ quản lý workload của team mình. Không dùng `ClusterRoleBinding` vì nó có thể cấp quyền xuyên namespace và làm mất cô lập với `demo`.

## Kiểm tra RBAC

```bash
kubectl auth can-i create deploy -n payments \
  --as payments-dev

kubectl auth can-i create deploy -n demo \
  --as payments-dev

kubectl auth can-i get secrets -n payments \
  --as payments-dev

kubectl auth can-i update rolebindings -n payments \
  --as payments-dev
```

Kỳ vọng:

```text
create deploy -n payments       -> yes
create deploy -n demo           -> no
get secrets -n payments         -> no
update rolebindings -n payments -> no
```

## Kiểm tra quota, limits và network

```bash
kubectl get resourcequota,limitrange -n payments
kubectl get networkpolicy -n payments
```

NetworkPolicy cần CNI có enforce policy, ví dụ minikube chạy với Calico.
