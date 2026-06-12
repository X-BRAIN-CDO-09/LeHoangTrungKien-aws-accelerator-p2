# Lab GitOps Notes

## ArgoCD Commands

```bash
kubectl get applications -n argocd
argocd app list
argocd app get demo-app
argocd app sync demo-app
```

## Kubernetes Verification

```bash
kubectl get pods -n demo
kubectl get svc -n demo
kubectl rollout status deployment/demo-app -n demo --timeout=180s
```

## GitOps Rule

Prefer changing Git and letting ArgoCD reconcile. Use manual cluster changes only for emergency debugging, then commit the final desired state back to Git.

