# Ngày A - RBAC và Admission Policy

## Mục tiêu

- Hiểu `Role`, `RoleBinding`, `ClusterRole`, `ClusterRoleBinding`, `ServiceAccount`.
- Thực hành 3 nhóm quyền: `developer`, `sre`, `viewer`.
- Dùng `kubectl auth can-i` để kiểm tra quyền thật thay vì đoán.
- Hiểu OPA/Gatekeeper: `ConstraintTemplate` và `Constraint`.
- Biết lúc nào dùng Gatekeeper, lúc nào dùng `ValidatingAdmissionPolicy`.
- Phân biệt `audit` và `enforce`.

## Checklist thực hành

- [ ] Tạo namespace và service account cho 3 role.
- [ ] Apply RBAC và kiểm tra `can-i`.
- [ ] Cài Gatekeeper.
- [ ] Apply 4 constraint enforce.
- [ ] Thử tạo workload vi phạm để xác nhận bị chặn.
- [ ] Đọc ví dụ native `ValidatingAdmissionPolicy`.

## Nội dung theory

- `01-rbac-foundation.md`: khái niệm RBAC và least privilege.
- `02-admission-control.md`: admission control và policy-as-code.
- `03-gatekeeper-patterns.md`: các mẫu Gatekeeper hay dùng cho hardening.
- `04-native-validating-admission-policy.md`: khi nào dùng policy native của Kubernetes.

## Cấu trúc thư mục

```text
day-a/
  theory/
  exercises/
    d1-rbac-admission/
      rbac/
      policies/
```
