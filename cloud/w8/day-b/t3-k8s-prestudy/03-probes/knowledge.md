# 03 - Probes Knowledge

## Probes Là Gì?

Probes là cơ chế để kubelet kiểm tra trạng thái container.

Ba loại probe thường gặp:

- `startupProbe`: container đã khởi động xong chưa.
- `readinessProbe`: container đã sẵn sàng nhận traffic chưa.
- `livenessProbe`: container còn sống khỏe không.

## Readiness Probe

Nếu readiness fail, Pod vẫn chạy nhưng Service sẽ không route traffic tới Pod đó.

## Liveness Probe

Nếu liveness fail nhiều lần, kubelet sẽ restart container.

## Startup Probe

Startup probe hữu ích cho ứng dụng khởi động chậm. Khi startup probe còn chạy, liveness/readiness có thể được trì hoãn.

## Kiểu Check

- HTTP GET.
- TCP socket.
- Exec command.

Ví dụ HTTP path thường là `/health` hoặc `/ready`.

