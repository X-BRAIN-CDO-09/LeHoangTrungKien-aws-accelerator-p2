# Tự động build image cho W10

W9 final đã có sẵn:

```text
cloud/w9/w9-lab-gitops-final/app/Dockerfile.backend
cloud/w9/w9-lab-gitops-final/app/Dockerfile.frontend
```

Vì vậy W10 không cần viết lại Dockerfile. Mục tiêu là tự động hóa 3 việc:

```text
build image
-> scan/sign nếu cần
-> cập nhật image tag trong GitOps manifest
```

## Cách nhanh bằng script local

Build backend và frontend với tag mặc định là git SHA:

```bash
cloud/w10/security-hardening-lab/scripts/build-flipkart-images.sh
```

Build, load vào kind và cập nhật manifest:

```bash
LOAD_KIND=true UPDATE_MANIFESTS=true \
  cloud/w10/security-hardening-lab/scripts/build-flipkart-images.sh
```

Build, load vào Minikube và cập nhật manifest:

```bash
LOAD_MINIKUBE=true UPDATE_MANIFESTS=true \
  cloud/w10/security-hardening-lab/scripts/build-flipkart-images.sh
```

Build, push lên Docker Hub và cập nhật manifest:

```bash
PUSH=true UPDATE_MANIFESTS=true \
  REGISTRY=docker.io IMAGE_NAMESPACE=kienlht \
  cloud/w10/security-hardening-lab/scripts/build-flipkart-images.sh
```

Sau khi script cập nhật manifest, dùng GitOps:

```bash
git diff cloud/w9/w9-lab-gitops-final/flipkart/k8s
git add cloud/w9/w9-lab-gitops-final/flipkart/k8s
git commit -m "[W10-Lab] Update Flipkart image tags"
git push origin main
```

ArgoCD sẽ sync image tag mới vào cluster.

## Cách tự động đầy đủ bằng CI

Với GitHub Actions, workflow nên chạy theo thứ tự:

```text
checkout
-> docker build backend/frontend
-> Trivy scan
-> Cosign sign
-> push image
-> cập nhật manifest bằng bot commit hoặc tạo PR
```

Trong W10, nếu chưa kịp làm bot commit, cách thực tế nhất là:

1. CI build + scan + sign + push image.
2. Người học cập nhật image tag trong manifest.
3. ArgoCD sync từ Git.

Điểm quan trọng: cluster không nên deploy image tag `latest` trong bài hardening. Dùng tag theo git SHA sẽ dễ trace hơn.
