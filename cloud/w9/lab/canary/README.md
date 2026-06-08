# Lab Canary Notes

## Argo Rollouts Commands

```bash
kubectl argo rollouts get rollout demo-app -n demo
kubectl argo rollouts promote demo-app -n demo
kubectl argo rollouts abort demo-app -n demo
kubectl argo rollouts retry rollout demo-app -n demo
```

## Verification

```bash
kubectl get rollout -n demo
kubectl get analysisrun -n demo
kubectl describe rollout demo-app -n demo
```

## Demo Script

1. Deploy a healthy image and show canary promotion.
2. Deploy a bad image or inject errors.
3. Show Prometheus query failing.
4. Show Argo Rollouts aborting the canary.
5. Explain how this protects users from bad deployments.

