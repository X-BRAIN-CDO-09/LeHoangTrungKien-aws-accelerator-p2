# Bài thực hành D3 - Platform Integration

## Mục tiêu

- Thêm resource governance cho namespace app.
- Gom security layer thành bootstrap có thể đưa vào GitOps.
- Tạo 2 runbook có thể dùng ngay.

## Cấu trúc

```text
d3-platform-integration/
  platform-bootstrap/
    namespace.yaml
    resourcequota.yaml
    limitrange.yaml
    platform-security-root.yaml
  runbooks/
    pod-compromise.md
    unsigned-image-rejected.md
```

## Kiểm tra

```bash
kubectl apply -f platform-bootstrap/namespace.yaml
kubectl apply -f platform-bootstrap/resourcequota.yaml
kubectl apply -f platform-bootstrap/limitrange.yaml
kubectl get resourcequota,limitrange -n team-a
```
