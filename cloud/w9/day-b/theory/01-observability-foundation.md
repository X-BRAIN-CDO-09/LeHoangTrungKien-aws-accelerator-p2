# 01 - Nền tảng Observability

## Từ monitoring đến observability

Monitoring thường bắt đầu bằng các câu hỏi đã biết trước, chẳng hạn CPU có vượt ngưỡng hay pod có bị restart hay không. Observability đi xa hơn: dùng dữ liệu hệ thống phát sinh để điều tra cả những vấn đề chưa được dự đoán trước.

Một hệ thống có observability tốt cần giúp trả lời được ba câu hỏi:

- Người dùng có đang nhận được dịch vụ tốt không?
- Nếu chất lượng giảm, thay đổi bắt đầu từ thời điểm nào?
- Thành phần nào có liên quan đến sự cố?

## Ba loại tín hiệu chính

### Metrics

Metrics là các giá trị số được ghi nhận theo thời gian. Metrics phù hợp để quan sát xu hướng, xây dựng dashboard và tạo cảnh báo.

Ví dụ:

- Request rate cho biết lượng traffic.
- Error rate thể hiện tỉ lệ request thất bại.
- Latency p95 cho biết 95% request hoàn thành trong bao lâu.
- CPU và memory phản ánh mức sử dụng tài nguyên.

### Logs

Logs ghi lại các sự kiện cụ thể, thường bao gồm timestamp, mức độ lỗi, message và context liên quan. Khi dashboard cho thấy error rate tăng, logs hỗ trợ tìm nguyên nhân chi tiết.

Logs nên có cấu trúc rõ ràng và chứa thông tin như request ID hoặc trace ID để việc tìm kiếm dễ hơn.

### Traces

Trace mô tả hành trình của một request qua các service. Mỗi bước xử lý được biểu diễn bằng một span. Trace hữu ích khi latency tăng nhưng chưa biết thời gian bị tiêu tốn ở service nào.

## Cách kết hợp tín hiệu

Một luồng điều tra có thể bắt đầu từ cảnh báo error rate trên Prometheus, chuyển sang Grafana để xác định thời điểm xảy ra, dùng Loki để đọc log lỗi, rồi dùng trace ID để tìm request cụ thể.

Không tín hiệu nào đủ mạnh khi đứng một mình. Giá trị thực tế đến từ khả năng liên kết metrics, logs và traces trong cùng một quá trình điều tra.

## Ghi nhớ

Observability không đồng nghĩa với việc tạo thật nhiều dashboard. Mục tiêu là thu thập đúng dữ liệu để đánh giá trải nghiệm người dùng và rút ngắn thời gian tìm nguyên nhân khi hệ thống có vấn đề.
