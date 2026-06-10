# 04 - Guardrails và cách luyện Canary

## Guardrail là gì?

Guardrail là điều kiện bảo vệ rollout khỏi việc promote một phiên bản có dấu hiệu không ổn định. Guardrail không cần chứng minh phiên bản hoàn hảo; nó cần phát hiện đủ sớm các tín hiệu nguy hiểm.

## Guardrails dùng trong lab

| Guardrail | Điều kiện đạt |
| --- | --- |
| Readiness | Pod mới sẵn sàng nhận traffic. |
| Success rate | Ít nhất 99% request thành công. |
| Fast burn | Error ratio 5m không vượt `0.0144`. |
| Analysis samples | Có đủ dữ liệu Prometheus để đưa ra quyết định. |

## Ba tình huống cần luyện

### Good release

Phiên bản mới hoạt động bình thường, metrics đạt yêu cầu và Rollout được promote qua từng bước.

### Bad release

Phiên bản mới trả nhiều lỗi. AnalysisRun thất bại và Rollout tự abort trước khi canary được promote toàn bộ.

### Missing telemetry

Ứng dụng chạy nhưng Prometheus không có dữ liệu. Đây không nên được xem là release thành công, vì hệ thống không có bằng chứng để đánh giá chất lượng.

## Forced-failure drill

Khi app W8 chưa được instrument metrics, có thể dùng AnalysisTemplate query `vector(0)` để cố tình tạo kết quả thất bại. Bài tập này không thay thế metrics thật, nhưng giúp luyện luồng AnalysisRun và auto-abort.

## Liên kết ba ngày học

- Day A đảm bảo thay đổi đi qua Git và ArgoCD.
- Day B cung cấp metrics, SLO và burn-rate signals.
- Day C dùng các signals đó để quyết định promote hoặc abort.

## Kết luận

Canary chỉ thật sự an toàn khi được kết nối với observability. Nếu không có metrics đáng tin cậy, canary chỉ là một rollout chậm hơn chứ chưa phải progressive delivery có kiểm soát.
