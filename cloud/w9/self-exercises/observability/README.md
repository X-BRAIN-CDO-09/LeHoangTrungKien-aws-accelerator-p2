# Lab Observability Notes

## Prometheus

```bash
kubectl get pods -n observability
kubectl port-forward svc/prometheus-operated -n observability 9090:9090
```

## Grafana

```bash
kubectl get svc -n observability
kubectl port-forward svc/grafana -n observability 3000:80
```

## Loki

Example LogQL:

```logql
{app="demo-app"}
```

## SLO Draft

- Availability SLI:
- Availability SLO:
- Latency SLI:
- Latency SLO:
- Alert window:

