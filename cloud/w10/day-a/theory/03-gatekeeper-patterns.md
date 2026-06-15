# Gatekeeper Patterns

Gatekeeper dựa trên OPA và Rego để viết policy-as-code cho Kubernetes.

## Hai object quan trọng

- `ConstraintTemplate`: định nghĩa logic policy và schema tham số.
- `Constraint`: instance của template, chọn phạm vi và tham số cụ thể.

## Audit và Enforce

- `dryrun`: audit mode, ghi nhận vi phạm nhưng chưa chặn request mới.
- `deny`: enforce mode, request mới vi phạm sẽ bị reject.

## Pattern phù hợp W10

1. Bắt buộc image tag không được là `latest`.
2. Bắt buộc `resources.requests` và `resources.limits`.
3. Bắt buộc `securityContext.runAsNonRoot: true`.
4. Cấm `privileged: true`.

## Cách học Gatekeeper

1. Apply template.
2. Apply constraint ở `dryrun`.
3. Xem `status.violations`.
4. Sửa workload cho hết vi phạm.
5. Chuyển sang `deny`.
