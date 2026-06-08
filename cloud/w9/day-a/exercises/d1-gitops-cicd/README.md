# Bài thực hành D1 - GitOps và CI/CD

## Mục tiêu

- Tạo workflow GitHub Actions cho plan-on-PR và apply-on-merge.
- Tạo ArgoCD root application theo mô hình App of Apps.
- Tạo child application cho demo app.
- Ghi lại cách rollback phù hợp với GitOps.

## Cấu trúc

```text
d1-gitops-cicd/
  .github/workflows/terraform-plan-apply.yml
  argocd/app-of-apps.yaml
  argocd/apps/demo-app.yaml
  rollback-notes.md
```

## Các bước thực hành

1. Kiểm tra workflow GitHub Actions.
2. Cập nhật `repoURL` trong manifest ArgoCD.
3. Apply root application vào namespace `argocd`.
4. Kiểm tra ArgoCD sync child application.
5. Thực hành rollback bằng `git revert`.

## Lệnh tham khảo

```bash
kubectl apply -f argocd/app-of-apps.yaml
kubectl get applications -n argocd
argocd app get demo-app
argocd app sync demo-app
```

