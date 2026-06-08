# Rollback Notes

## Preferred GitOps Rollback

Use Git revert when the cluster is managed by ArgoCD:

```bash
git revert <bad-commit-sha>
git push
argocd app sync demo-app
```

This keeps Git and the cluster aligned.

## Emergency Rollback

Use Kubernetes rollback only when immediate recovery is needed:

```bash
kubectl rollout undo deployment/demo-app -n demo
kubectl rollout status deployment/demo-app -n demo --timeout=180s
```

After emergency rollback, update Git so ArgoCD does not re-apply the bad version.

