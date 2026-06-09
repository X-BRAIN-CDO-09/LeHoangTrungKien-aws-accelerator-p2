# Bài thực hành D2 - Observability

## Mục tiêu

- Deploy OTel Collector để nhận OTLP và expose metrics cho Prometheus.
- Chuẩn bị dashboard Grafana tập trung vào traffic, error và latency.
- Tạo recording rules để tính error ratio theo nhiều cửa sổ thời gian.
- Tạo multi-window burn-rate alerts dựa trên availability SLO 99.9%.
- Ghi lại truy vấn PromQL và LogQL phục vụ điều tra.

## Cấu trúc

```text
d2-observability/
  otel/
    collector-config.yaml
    collector-deployment.yaml
  dashboards/README.md
  alert-rules/
    slo-recording-rules.yaml
    slo-burn-rate-rules.yaml
```

## Giả định

- Cluster đã có Prometheus Operator hoặc kube-prometheus-stack.
- Ứng dụng phát sinh metric `http_requests_total`.
- Metric có label `app="demo-app"` và `status`.
- Availability SLO mục tiêu là 99.9%.

## Các bước thực hành

1. Tạo namespace `observability`.
2. Apply ConfigMap, Deployment và Service của OTel Collector.
3. Kiểm tra Collector nhận dữ liệu và expose metrics tại port `9464`.
4. Apply recording rules trước để Prometheus tính error ratio.
5. Apply burn-rate alert rules.
6. Dùng PromQL kiểm tra request rate, error ratio và availability.
7. Tạo dashboard Grafana theo các panel gợi ý.
8. Ghi lại evidence trong thư mục lab.

## Lệnh tham khảo

```bash
kubectl create namespace observability
kubectl apply -f otel/collector-config.yaml
kubectl apply -f otel/collector-deployment.yaml
kubectl rollout status deployment/otel-collector -n observability --timeout=180s
kubectl logs deployment/otel-collector -n observability
kubectl apply -f alert-rules/slo-recording-rules.yaml
kubectl apply -f alert-rules/slo-burn-rate-rules.yaml
kubectl get prometheusrule -n observability
```

## Kiểm tra nhanh

```bash
kubectl port-forward svc/otel-collector -n observability 9464:9464
curl http://localhost:9464/metrics
```

## Kết quả mong đợi

- OTel Collector chạy ổn định và nhận được OTLP.
- Prometheus thấy các recording rules.
- Dashboard hiển thị traffic, errors và latency.
- Fast burn alert phản ứng với lỗi lớn.
- Slow burn alert phản ứng với lỗi kéo dài.
