# W9 Reflection

## What I Learned

- GitOps changes the deployment flow from manual `kubectl apply` to Git as the source of truth.
- CI/CD should validate changes before merge, while ArgoCD continuously reconciles the desired state after merge.
- Observability is not only logs or dashboards; it combines metrics, logs, traces and user-focused SLOs.
- Canary delivery reduces release risk by sending only a small percentage of traffic to a new version first.

## Key Concepts

- GitOps:
- ArgoCD:
- App of Apps:
- Sync wave:
- Rollback:
- SLI:
- SLO:
- Burn rate:
- OpenTelemetry:
- Argo Rollouts:
- AnalysisTemplate:

## Lab Evidence

- ArgoCD application synced:
- Prometheus target healthy:
- Grafana dashboard created:
- Loki logs visible:
- Burn-rate alert rule loaded:
- Canary rollout completed:
- Canary rollout abort tested:

## Personal Notes

Write the main lessons learned, blockers, and commands that helped debug the lab.

