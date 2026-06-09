# 04 - Kết nối Prometheus, Grafana và Loki

## Mỗi công cụ giải quyết một phần bài toán

Observability stack trong lab gồm nhiều công cụ vì mỗi công cụ có thế mạnh riêng:

| Công cụ | Vai trò chính |
| --- | --- |
| Prometheus | Thu thập, lưu trữ và truy vấn metrics theo thời gian. |
| Grafana | Trực quan hóa dữ liệu thành dashboard. |
| Loki | Lưu trữ và truy vấn logs dựa trên labels. |
| OTel Collector | Nhận, xử lý và chuyển telemetry data. |

## Prometheus

Prometheus định kỳ scrape metrics từ các endpoint. Dữ liệu được truy vấn bằng PromQL để tạo dashboard, recording rules và alert rules.

Prometheus phù hợp với dữ liệu dạng số như request rate, error ratio và latency histogram. Metric label cần được lựa chọn cẩn thận để tránh cardinality quá cao.

## Grafana

Grafana không phải nơi tạo metrics. Grafana kết nối đến data source như Prometheus hoặc Loki để hiển thị dữ liệu.

Một dashboard hữu ích nên giúp trả lời:

- Traffic hiện tại có bất thường không?
- Error ratio có vượt mức bình thường không?
- Latency p95 đang thay đổi như thế nào?
- SLO có nguy cơ bị vi phạm không?

## Loki

Loki lưu trữ logs và dùng LogQL để truy vấn. Loki ưu tiên index labels thay vì index toàn bộ nội dung log, vì vậy labels cần ổn định và có số lượng giá trị hợp lý.

Ví dụ labels phù hợp:

- `namespace`
- `app`
- `container`
- `level`

Không nên dùng request ID làm label vì mỗi request tạo một giá trị mới, gây cardinality rất cao.

## Luồng điều tra mẫu

```text
Prometheus alert -> Grafana dashboard -> Loki logs -> xác định nguyên nhân
```

Nếu có tracing backend, trace ID trong log có thể được dùng để mở trace tương ứng và xem request bị chậm ở span nào.

## Kết luận

Prometheus giúp phát hiện dấu hiệu bất thường, Grafana giúp quan sát bối cảnh, Loki hỗ trợ đọc chi tiết sự kiện, còn OTel Collector giúp chuẩn hóa đường đi của telemetry.
