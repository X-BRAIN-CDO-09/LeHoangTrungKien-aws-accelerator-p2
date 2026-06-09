# Gợi ý Dashboard Grafana

Dashboard cho `demo-app` nên tập trung vào chất lượng người dùng nhận được thay vì chỉ hiển thị tài nguyên hệ thống.

## Các panel chính

- Tổng request rate và request rate theo status code.
- Error ratio của ứng dụng.
- P95 latency.
- Availability SLI.
- Mức tiêu hao error budget.
- CPU và memory của pod để hỗ trợ điều tra nguyên nhân.
- Logs gần nhất của `demo-app` từ Loki.

## PromQL tham khảo

### Request rate

```promql
sum(rate(http_requests_total{app="demo-app"}[5m]))
```

### Error ratio

```promql
sum(rate(http_requests_total{app="demo-app",status=~"5.."}[5m]))
/
clamp_min(sum(rate(http_requests_total{app="demo-app"}[5m])), 1e-9)
```

### P95 latency

```promql
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket{app="demo-app"}[5m])) by (le)
)
```

### Availability SLI

```promql
1 - demo_app:http_request_errors_per_requests:ratio_rate5m
```

## LogQL tham khảo

```logql
{app="demo-app"} |= "error"
```

Có thể mở rộng bằng cách filter theo namespace hoặc parser JSON nếu ứng dụng xuất structured logs.
