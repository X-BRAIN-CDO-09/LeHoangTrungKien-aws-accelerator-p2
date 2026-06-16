# Bài thực hành D2 - Secrets và Supply Chain

## Mục tiêu

- Đồng bộ secret từ AWS Secrets Manager vào namespace `team-a`.
- Ghi chú cách rotate secret trong < 60 giây.
- Thêm workflow Trivy cho repo.
- Chuẩn bị verify-image policy cho cluster.

## Cấu trúc

```text
d2-secrets-supply-chain/
  eso/
    cluster-secret-store.yaml
    external-secret.yaml
    demo-secret-consumer.yaml
  signing/
    cosign-commands.md
    kyverno-verify-images.yaml
  ci-trivy/
    github-actions-trivy.yaml
```

## Ghi chú

Manifest ESO trong bài này dùng mẫu kết nối AWS qua service account / IRSA. Nếu đang học local Minikube, có thể thay bằng static credentials tạm thời để hiểu luồng, nhưng bài cuối nên quay về IRSA.
