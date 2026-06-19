# Payments App

`payments-api` dùng cùng image đã scan và ký ở Lab 2.2:

```text
ghcr.io/x-brain-cdo-09/lehoangtrungkien-aws-accelerator-p2/w10-api:0.0.4
```

App có:

- `owner` label trên Deployment và Pod template.
- resource requests/limits.
- `runAsNonRoot` và `runAsUser: 10001`.
- `imagePullSecrets` lấy từ ESO-managed `ghcr-pull-secret`.

Các manifest trong `tests/` dùng để lấy evidence thủ công và không được ArgoCD sync.
