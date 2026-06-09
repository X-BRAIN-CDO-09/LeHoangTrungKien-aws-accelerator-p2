# Ngày B - Observability, SLO, SLI và OpenTelemetry

## Mục tiêu

- Hiểu sự khác nhau giữa metrics, logs và traces.
- Nắm vai trò của OpenTelemetry SDK và OpenTelemetry Collector.
- Sử dụng Prometheus để thu thập metrics, Grafana để hiển thị dashboard và Loki để lưu logs.
- Định nghĩa SLI/SLO cho availability và latency.
- Hiểu cách hoạt động của multi-window burn-rate alerts.

## Ví dụ SLI

- Availability SLI: số request thành công chia cho tổng số request.
- Latency SLI: phần trăm request hoàn thành dưới ngưỡng thời gian mục tiêu.

## Ví dụ SLO

- Availability SLO: 99.9% request thành công trong 30 ngày.
- Latency SLO: 95% request hoàn thành dưới 300ms trong 30 ngày.

## Cửa sổ Burn Rate

- Fast burn: dùng cửa sổ 1h và 5m để phát hiện lỗi nghiêm trọng nhanh.
- Slow burn: dùng cửa sổ 6h và 30m để phát hiện lỗi kéo dài.

## Checklist thực hành

- [ ] Thêm cấu hình OTel Collector.
- [ ] Deploy OTel Collector và kiểm tra các endpoint.
- [ ] Xác nhận Prometheus scrape được metrics của ứng dụng.
- [ ] Tạo ghi chú dashboard Grafana.
- [ ] Thêm ví dụ truy vấn logs bằng Loki.
- [ ] Tạo recording rules cho error ratio.
- [ ] Thêm rule cảnh báo SLO burn rate.

## Nội dung theory

- `01-observability-foundation.md`: cách kết hợp metrics, logs và traces để điều tra hệ thống.
- `02-opentelemetry.md`: instrumentation, OTel SDK, Collector và telemetry pipeline.
- `03-sli-slo-burn-rate.md`: cách xây dựng SLI/SLO, error budget và multi-window burn rate.
- `04-observability-stack.md`: vai trò của Prometheus, Grafana, Loki và OTel Collector.

## Cấu trúc thư mục

```text
day-b/
  theory/      # Ghi chú lý thuyết observability, OTel, SLO/SLI
  exercises/   # Bài thực hành OTel, dashboard, alert rules
```
