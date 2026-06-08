# 02 - OpenTelemetry

## OpenTelemetry là gì?

OpenTelemetry là bộ tiêu chuẩn và công cụ mã nguồn mở dùng để thu thập telemetry data như metrics, logs và traces. OpenTelemetry giúp ứng dụng không bị phụ thuộc quá chặt vào một vendor cụ thể.

## OTel SDK

OTel SDK được tích hợp vào ứng dụng để tạo ra telemetry data. Ví dụ ứng dụng có thể gửi:

- Request count.
- Request latency.
- Error count.
- Trace span.

## OTel Collector

OTel Collector nhận dữ liệu từ ứng dụng, xử lý và export đến hệ thống khác.

Luồng cơ bản:

```text
Application -> OTel SDK -> OTel Collector -> Prometheus/Grafana/Tracing backend
```

## Thành phần Collector

- Receiver: nhận dữ liệu.
- Processor: xử lý dữ liệu, ví dụ batch hoặc filter.
- Exporter: gửi dữ liệu đến nơi lưu trữ hoặc quan sát.
- Pipeline: nối receiver, processor và exporter lại với nhau.

