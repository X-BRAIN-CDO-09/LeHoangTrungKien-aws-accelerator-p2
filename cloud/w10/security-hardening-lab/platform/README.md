# Lab Platform

Folder này chứa guardrail vận hành cho lab W10.

## Apply quota và limit cho Flipkart

```bash
kubectl apply -f cloud/w10/security-hardening-lab/platform/60-resourcequota-flipkart.yaml
kubectl apply -f cloud/w10/security-hardening-lab/platform/61-limitrange-flipkart.yaml
```

## Kiểm tra

```bash
kubectl get resourcequota,limitrange -n flipkart
kubectl describe resourcequota flipkart-quota -n flipkart
kubectl describe limitrange default-container-limits -n flipkart
```

## ArgoCD root app mẫu

`62-argocd-platform-security-root.yaml` là skeleton để quản lý W10 security layer bằng GitOps. Cần kiểm tra lại `repoURL` và `path` trước khi apply thật.
