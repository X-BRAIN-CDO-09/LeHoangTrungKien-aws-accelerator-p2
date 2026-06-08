# 01 - Nền tảng Observability

## Observability là gì?

Observability là khả năng hiểu trạng thái bên trong của hệ thống dựa trên các tín hiệu bên ngoài như metrics, logs và traces. Mục tiêu không chỉ là biết hệ thống có lỗi hay không, mà còn hiểu lỗi xảy ra ở đâu, khi nào và ảnh hưởng đến người dùng như thế nào.

## Metrics

Metrics là dữ liệu dạng số theo thời gian, ví dụ:

- Số lượng request mỗi giây.
- Tỉ lệ lỗi.
- CPU, memory.
- Latency p95 hoặc p99.

Metrics phù hợp để cảnh báo và quan sát xu hướng.

## Logs

Logs là các dòng sự kiện chi tiết do ứng dụng hoặc hệ thống sinh ra. Logs hữu ích khi cần điều tra nguyên nhân cụ thể của lỗi.

## Traces

Traces theo dõi đường đi của một request qua nhiều service. Traces đặc biệt hữu ích trong hệ thống microservices vì một request có thể đi qua nhiều thành phần khác nhau.

## Ba câu hỏi quan trọng

- Hệ thống có đang phục vụ người dùng tốt không?
- Nếu không tốt, phần nào đang gây lỗi?
- Lỗi này ảnh hưởng bao nhiêu người dùng và nghiêm trọng đến mức nào?

