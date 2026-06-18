# Lab 2.2 - Image Signature Policy

Policy Controller chỉ enforce trên namespace có label:

```text
policy.sigstore.dev/include=true
```

Đừng gắn label này trước khi image đang chạy đã được ký, nếu không admission có thể chặn chính workload của lab.

## Cách bật verify sau khi image đã ký

1. Generate key:

```bash
cosign generate-key-pair
```

2. Lưu private key vào GitHub Secret:

```text
COSIGN_PRIVATE_KEY
COSIGN_PASSWORD
```

3. Commit public key vào `signing/cosign.pub` và dán cùng nội dung vào `policies/cluster-image-policy.yaml`.

4. Sau khi workflow đã ký tag image mà Rollout đang dùng, bật enforce cho namespace `demo`:

```bash
kubectl label namespace demo policy.sigstore.dev/include=true
```

## Nghiệm thu

```bash
kubectl get clusterimagepolicy
kubectl describe clusterimagepolicy require-signed-w10-api
kubectl get ns demo --show-labels
```

Image chưa ký phải bị admission reject. Image đã ký bằng key tương ứng phải pass.
