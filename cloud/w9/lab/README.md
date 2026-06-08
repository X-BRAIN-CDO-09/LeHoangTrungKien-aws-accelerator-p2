# W9 Lab - GitOps-ify W8 Platform

## Lab Goal

Convert the W8 platform into a GitOps-managed delivery flow with observability and canary deployment.

## Target Outcome

- ArgoCD syncs the platform from Git.
- Manual `kubectl apply` is no longer the normal deployment path.
- Prometheus collects application and platform metrics.
- Grafana shows SLO-related dashboards.
- Loki stores application logs.
- Argo Rollouts performs canary deployment.
- Bad releases are automatically aborted by metric checks.

## Suggested Flow

1. Prepare W8 manifests or Helm/Kustomize layout.
2. Register the application in ArgoCD.
3. Add observability stack.
4. Add SLO and burn-rate alert rules.
5. Replace Deployment with Rollout.
6. Add AnalysisTemplate for canary checks.
7. Capture evidence for show-and-tell.

## Evidence Checklist

- [ ] ArgoCD app health is `Healthy`.
- [ ] ArgoCD sync status is `Synced`.
- [ ] Prometheus target is `UP`.
- [ ] Grafana dashboard shows request rate, errors and latency.
- [ ] Loki query returns demo-app logs.
- [ ] Canary rollout succeeds for a good version.
- [ ] Canary rollout aborts for a bad version.

