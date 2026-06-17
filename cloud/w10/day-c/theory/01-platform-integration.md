# Platform Integration

W10 không thêm nhiều tool cho vui. Mục tiêu là kết nối các lớp đã học:

- W8: cluster và infra có thể dựng lại
- W9: GitOps, observability, canary
- W10: RBAC, policy, secrets, quota, signed image

## Fresh cluster < 2h

Mục tiêu maturity là:

```text
fresh cluster
-> bootstrap ArgoCD
-> sync platform apps
-> observability on
-> rollout on
-> security policies on
-> app deploy pass policy
```

Nếu phải dùng tay quá nhiều lệnh ngoài Git, mini platform chưa thật sự sẵn sàng.
