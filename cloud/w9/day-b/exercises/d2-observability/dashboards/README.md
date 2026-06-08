# Grafana Dashboard Notes

Create a dashboard for `demo-app` with these panels:

- Request rate by status code.
- Error rate percentage.
- P95 latency.
- Availability SLI.
- Latency SLI.
- Pod CPU and memory.
- Recent Loki logs for the application.

## Example PromQL

```promql
sum(rate(http_requests_total{app="demo-app"}[5m]))
```

```promql
sum(rate(http_requests_total{app="demo-app",status=~"5.."}[5m]))
/
sum(rate(http_requests_total{app="demo-app"}[5m]))
```

```promql
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket{app="demo-app"}[5m])) by (le)
)
```

## Example LogQL

```logql
{app="demo-app"} |= "error"
```

