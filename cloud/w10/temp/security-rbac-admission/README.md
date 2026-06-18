# W10 Morning - RBAC + Admission Policy

Folder này triển khai phần lab từ slide `w10_morning_rbac_admission`: RBAC, Pod ServiceAccount và OPA Gatekeeper admission policy cho namespace `demo`.

## Mục tiêu

- Phân biệt `Role`/`RoleBinding` với `ClusterRole`/`ClusterRoleBinding`.
- Dùng `kubectl auth can-i` để kiểm tra quyền.
- Gắn ServiceAccount riêng cho Pod/Workload `api`.
- Cài Gatekeeper qua ArgoCD.
- Enforce 4 luật admission chính:
  - cấm image tag `:latest`
  - bắt buộc container có `resources.limits.cpu` và `resources.limits.memory`
  - cấm `runAsUser: 0`
  - cấm `hostNetwork: true`
- Thêm 2 policy mở rộng:
  - bắt buộc label `owner` cho Pod và Pod template của Deployment/Rollout
  - chỉ cho image từ registry được duyệt

## Cấu trúc

```text
security-rbac-admission/
  rbac/
    serviceaccounts.yaml
    roles.yaml
    rolebindings.yaml
    clusterrole-platform-viewer.yaml
    clusterrolebinding-platform-viewer.yaml
  workload-identity/
    api-serviceaccount.yaml
    api-pod-reader-role.yaml
    api-pod-reader-binding.yaml
  gatekeeper/
    templates/
    constraints-warn/
    constraints/
    tests/
```

## GitOps flow

Các ArgoCD Application nằm ở:

```text
argocd/apps/gatekeeper.yaml
argocd/apps/security-rbac.yaml
argocd/apps/security-workload-identity.yaml
argocd/apps/security-gatekeeper-templates.yaml
argocd/apps/security-gatekeeper-constraints.yaml
```

Thứ tự sync:

```text
app-common
-> gatekeeper controller
-> rbac + workload identity + gatekeeper templates
-> gatekeeper constraints
-> app-api
```

Mặc định ArgoCD sync constraint ở chế độ `warn` từ:

```text
gatekeeper/constraints-warn
```

Sau khi audit sạch và chắc chắn workload `api` không vi phạm policy, chuyển Application `security-gatekeeper-constraints` sang bộ enforce:

```bash
kubectl patch application security-gatekeeper-constraints -n argocd \
  --type merge \
  -p '{"spec":{"source":{"path":"cloud/w10/temp/security-rbac-admission/gatekeeper/constraints"}}}'
```

Bộ `constraints/` dùng cùng tên constraint với `constraints-warn/`, nên ArgoCD sẽ cập nhật `enforcementAction` từ `warn` sang `deny`.

## Kiểm tra RBAC

```bash
kubectl auth can-i create deploy -n demo \
  --as system:serviceaccount:demo:alice

kubectl auth can-i create deploy -n kube-system \
  --as system:serviceaccount:demo:alice

kubectl auth can-i get pods -A \
  --as system:serviceaccount:demo:bob

kubectl auth can-i delete nodes \
  --as system:serviceaccount:demo:carol

kubectl auth can-i list pods -n demo \
  --as system:serviceaccount:demo:api
```

Kết quả mong đợi:

```text
alice create deploy -n demo       -> yes
alice create deploy -n kube-system -> no
bob get pods -A                   -> yes
carol delete nodes                -> no
api list pods -n demo             -> yes
```

Lưu ý: `alice`, `bob`, `carol` trong lab này là `ServiceAccount`, không phải Kubernetes `User`. Vì vậy lệnh `--as alice` sẽ trả `no`; cần dùng đúng identity dạng `system:serviceaccount:<namespace>:<name>`.

## Kiểm tra Gatekeeper

Các manifest test nằm trong:

```text
security-rbac-admission/gatekeeper/tests
```

Chạy từng file để lấy evidence:

```bash
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-latest.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-missing-limits.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-root-user.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-host-network.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-missing-owner.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-deployment-missing-owner.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-rollout-missing-owner.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-deny-unapproved-registry.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-allow-secure-pod.yaml
kubectl apply -f security-rbac-admission/gatekeeper/tests/test-allow-owner-workloads.yaml
```

Ở chế độ `warn`, các file vi phạm sẽ apply được nhưng Gatekeeper ghi cảnh báo/audit. Sau khi chuyển sang bộ `constraints/` dùng `deny`, các file `test-deny-*` phải bị reject; `test-allow-secure-pod.yaml` và `test-allow-owner-workloads.yaml` phải apply được.
