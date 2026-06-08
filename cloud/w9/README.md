# W9 - Deliver Smartly: GitOps + Observability + Canary

Week 9 focuses on moving the W8 platform from manual deployment to a safer delivery model:

- GitOps-managed deployment with ArgoCD.
- CI/CD guardrails with GitHub Actions.
- Observability stack for metrics, logs, traces, SLO and burn-rate alerts.
- Progressive delivery with canary rollout and automatic abort when metrics are bad.

## Schedule

| Day | Topic | Outcome |
| --- | --- | --- |
| T2 08/06 | D1 GitOps and CI/CD | GitHub Actions plan-on-PR/apply-on-merge, ArgoCD app-of-apps, rollback notes |
| T3 09/06 | D2 Observability | OTel Collector, Prometheus/Grafana/Loki notes, SLO and burn-rate alert rules |
| T4 10/06 | D3 Progressive Delivery | Argo Rollouts, AnalysisTemplate, abort criteria |
| T5 11/06 | Onsite Lab | GitOps-ify W8 platform and add observability |
| T6 12/06 | Lab completion | Canary demo, evidence, show-and-tell |

## Repository Layout

```text
cloud/w9/
  day-a/      # GitOps and CI/CD
  day-b/      # Observability, SLO, SLI, OTel
  day-c/      # Progressive delivery and canary
  lab/        # Integrated W9 lab
  reflection.md
```

## Final Goal

By the end of W9, the W8 cluster should be GitOps-managed by ArgoCD, observed through metrics/logs/traces, measured by SLO and burn-rate alerts, and deployed through canary rollout with automatic abort when service metrics become unhealthy.

