# Bài thực hành D2 - Observability

## Mục tiêu

- Tạo cấu hình OTel Collector.
- Chuẩn bị dashboard Grafana.
- Viết PrometheusRule cho SLO burn rate.
- Ghi lại truy vấn PromQL và LogQL phục vụ debug.

## Cấu trúc

```text
d2-observability/
  otel/collector-config.yaml
  dashboards/README.md
  alert-rules/slo-burn-rate-rules.yaml
```

## Các bước thực hành

1. Tạo namespace `observability`.
2. Apply cấu hình OTel Collector.
3. Kiểm tra Prometheus scrape metrics.
4. Tạo dashboard Grafana theo các panel gợi ý.
5. Apply burn-rate alert rules.
6. Ghi lại evidence trong thư mục lab.

## Lệnh tham khảo

```bash
kubectl create namespace observability
kubectl apply -f otel/collector-config.yaml
kubectl apply -f alert-rules/slo-burn-rate-rules.yaml
kubectl get prometheusrule -n observability
```

