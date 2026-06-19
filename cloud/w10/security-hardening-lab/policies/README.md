# Lab Policies

Folder này chứa admission policy dùng trực tiếp cho namespace `flipkart`.

## Gatekeeper

```bash
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/20-template-required-resources.yaml
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/21-template-required-security-context.yaml
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/22-template-disallow-latest-tag.yaml
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/23-template-disallow-privileged.yaml
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/24-constraints-enforce-workload-standards.yaml
```

## Test reject

```bash
kubectl apply -f cloud/w10/security-hardening-lab/policies/gatekeeper/29-test-deny-insecure-pod.yaml
```

Workload này phải bị reject vì dùng `latest`, chạy `privileged`, thiếu `runAsNonRoot` và thiếu requests/limits.
