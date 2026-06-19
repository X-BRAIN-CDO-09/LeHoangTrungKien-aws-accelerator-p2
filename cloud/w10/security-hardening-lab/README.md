# W10 Security Hardening Lab - 6 Risk Cluster Cleanup và Enforcement

Security hardening lab này dùng để tổng hợp W10 thành bài "clean up cluster" thay vì học từng concept riêng lẻ.

Điểm bắt đầu của lab là W9 final:

```text
cloud/w9/w9-lab-gitops-final
```

Không cần quay lại W8 hoặc viết Terraform mới cho W10. W10 hardening trực tiếp workload Flipkart đã có GitOps, observability và canary từ W9.

## Mục tiêu

Tìm và sửa 6 nhóm rủi ro:

1. Workload chạy `latest` tag.
2. Container `privileged` hoặc thiếu `runAsNonRoot`.
3. Workload không có requests/limits.
4. Secret nằm tay trong manifest hoặc env cứng.
5. Image chưa scan / chưa sign.
6. Namespace không có quota / limit và quyền quá rộng.

## Cách làm

```text
phát hiện
-> sửa workload
-> thêm policy enforce
-> verify vi phạm mới bị chặn
-> ghi evidence
```

## Thư mục

```text
security-hardening-lab/
  README.md
  BUILD-IMAGE-AUTOMATION.md
  six-risk-checklist.md
  base/
    00-namespaces.yaml
  rbac/
    10-serviceaccounts.yaml
    11-roles.yaml
    12-rolebindings.yaml
  policies/
    gatekeeper/
      20-template-required-resources.yaml
      21-template-required-security-context.yaml
      22-template-disallow-latest-tag.yaml
      23-template-disallow-privileged.yaml
      24-constraints-enforce-workload-standards.yaml
      29-test-deny-insecure-pod.yaml
    validating-admission-policy/
      25-native-disallow-latest-policy.yaml
  secrets/
    eso/
      30-cluster-secret-store-aws.yaml
      31-external-secret-flipkart-backend.yaml
      32-demo-secret-consumer.yaml
  supply-chain/
    ci/
    signing/
      50-kyverno-verify-signed-images.yaml
  platform/
    60-resourcequota-flipkart.yaml
    61-limitrange-flipkart.yaml
    62-argocd-platform-security-root.yaml
  policy-test-workloads/
    90-insecure-workload-denied.yaml
    91-secure-workload-allowed.yaml
  runbooks/
  scripts/
    apply-security-hardening-lab.sh
    port-forward-w10.sh
    build-flipkart-images.sh
  ci/
    w10-build-flipkart-images.example.yml
  evidence/
    README.md
```

## Script hỗ trợ

Chạy core security hardening lab theo đúng thứ tự:

```bash
cloud/w10/security-hardening-lab/scripts/apply-security-hardening-lab.sh
```

Chạy thêm workload test để lấy evidence policy reject/allow:

```bash
RUN_POLICY_TESTS=true \
  cloud/w10/security-hardening-lab/scripts/apply-security-hardening-lab.sh
```

Mở port-forward tự động:

```bash
cloud/w10/security-hardening-lab/scripts/port-forward-w10.sh all
```

Build image backend/frontend tự động:

```bash
cloud/w10/security-hardening-lab/scripts/build-flipkart-images.sh
```

Build và cập nhật manifest để ArgoCD sync:

```bash
PUSH=true UPDATE_MANIFESTS=true \
  REGISTRY=docker.io IMAGE_NAMESPACE=kienlht \
  cloud/w10/security-hardening-lab/scripts/build-flipkart-images.sh
```

## Thứ tự chạy lab gợi ý

Script `apply-security-hardening-lab.sh` là entrypoint chính. Các lệnh bên dưới dùng khi muốn debug từng bước:

```bash
kubectl apply -f cloud/w10/security-hardening-lab/base/00-namespaces.yaml
kubectl apply -f cloud/w10/security-hardening-lab/rbac/
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/
kubectl apply -f cloud/w10/security-hardening-lab/secrets/eso/
kubectl apply -f cloud/w10/security-hardening-lab/platform/60-resourcequota-flipkart.yaml
kubectl apply -f cloud/w10/security-hardening-lab/platform/61-limitrange-flipkart.yaml
```

File `29-test-deny-insecure-pod.yaml` và các file trong `policy-test-workloads/` chỉ dùng để tạo evidence policy reject/allow, không phải workload production của Flipkart.

Khi chạy lab T5-T6, chỉ cần dùng các file trong `cloud/w10/security-hardening-lab`. Các bài học theo ngày vẫn để riêng để học theory/exercise, không cần tham chiếu ngược lại trong lúc chạy lab.

## Evidence cần lưu

- `kubectl auth can-i` cho 3 role.
- Gatekeeper reject workload vi phạm.
- ESO secret refresh thành công.
- Trivy workflow fail đúng như mong đợi.
- Verify-image policy reject image unsigned.
- Quota/LimitRange được tạo và namespace không vượt ngưỡng.
