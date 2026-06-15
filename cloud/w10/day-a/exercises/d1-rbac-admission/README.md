# Bài thực hành D1 - RBAC và Admission

## Mục tiêu

- Tạo 3 role `developer`, `sre`, `viewer`.
- Kiểm tra quyền bằng `kubectl auth can-i`.
- Cài và áp dụng 4 Gatekeeper constraint cho namespace app.
- Thử một `ValidatingAdmissionPolicy` native để so sánh.

## Cấu trúc

```text
d1-rbac-admission/
  rbac/
    namespace.yaml
    serviceaccounts.yaml
    roles.yaml
    rolebindings.yaml
  policies/
    gatekeeper/
      template-k8srequiredresources.yaml
      template-k8srequiredsecuritycontext.yaml
      template-k8sdisallowlatest.yaml
      template-k8sdisallowprivileged.yaml
      constraints.yaml
      violating-pod.yaml
    validating-admission-policy/
      disallow-latest-policy.yaml
```

## Thứ tự gợi ý

```bash
kubectl apply -f rbac/namespace.yaml
kubectl apply -f rbac/serviceaccounts.yaml
kubectl apply -f rbac/roles.yaml
kubectl apply -f rbac/rolebindings.yaml
```

Kiểm tra:

```bash
kubectl auth can-i create deployment --as system:serviceaccount:team-a:developer -n team-a
kubectl auth can-i get secrets --as system:serviceaccount:team-a:developer -n team-a
kubectl auth can-i patch deployment --as system:serviceaccount:team-a:sre -n team-a
kubectl auth can-i get pods --as system:serviceaccount:team-a:viewer -n team-a
```

Sau đó cài Gatekeeper rồi apply `policies/gatekeeper`.

## Kết quả mong đợi

- `developer` deploy được workload nhưng không đọc `Secret`.
- `sre` được rollout/debug workload.
- `viewer` chỉ đọc.
- Workload vi phạm `latest`, `privileged`, thiếu `runAsNonRoot`, thiếu `requests/limits` bị chặn.
