# 02 - OpenTelemetry

## Vai trò của OpenTelemetry

Mỗi observability backend có thể sử dụng một cách thu thập dữ liệu khác nhau. Nếu ứng dụng tích hợp trực tiếp với từng công cụ, việc thay đổi backend sẽ tốn nhiều công sức.

OpenTelemetry cung cấp một cách chung để tạo, nhận, xử lý và chuyển telemetry data. Nhờ đó, ứng dụng có thể gửi dữ liệu theo chuẩn OTLP mà không cần phụ thuộc chặt vào Prometheus, Grafana hoặc một vendor cụ thể.

## Instrumentation và OTel SDK

Instrumentation là quá trình bổ sung khả năng phát sinh telemetry cho ứng dụng. Có hai hướng phổ biến:

- Auto-instrumentation: thu thập dữ liệu với ít thay đổi source code.
- Manual instrumentation: chủ động tạo metric hoặc span phù hợp với nghiệp vụ.

OTel SDK chạy cùng ứng dụng và chịu trách nhiệm tạo dữ liệu như request count, latency, error count hoặc trace span.

## Collector đứng giữa để làm gì?

OTel Collector đóng vai trò trung gian giữa ứng dụng và observability backend:

```text
Application -> OTel SDK -> OTLP -> OTel Collector -> Observability backends
```

Đưa Collector vào giữa giúp ứng dụng không cần biết dữ liệu cuối cùng sẽ được gửi đến đâu. Collector cũng có thể batch, filter hoặc bổ sung thông tin trước khi export.

## Cấu trúc một pipeline

- Receiver: nhận dữ liệu.
- Processor: xử lý dữ liệu trước khi gửi tiếp.
- Exporter: chuyển dữ liệu sang backend hoặc endpoint đích.
- Service pipeline: xác định receiver, processor và exporter được dùng cho từng loại tín hiệu.

Ví dụ:

```yaml
service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus, debug]
```

## Collector deployment patterns

- Agent: Collector chạy gần workload, thường theo kiểu DaemonSet hoặc sidecar.
- Gateway: nhiều workload gửi dữ liệu về một Collector trung tâm.

Lab W9 sử dụng cách đơn giản gần với gateway: ứng dụng gửi OTLP đến một Collector trong namespace observability.

## Ghi nhớ

OTel SDK tạo telemetry trong ứng dụng. OTel Collector nhận và chuyển telemetry. Prometheus, Loki hoặc tracing backend mới là nơi lưu trữ và truy vấn dữ liệu.
