# 01 - Progressive Delivery

## Vấn đề của việc deploy toàn bộ cùng lúc

Một phiên bản có thể vượt qua CI nhưng vẫn lỗi khi gặp traffic thật, dữ liệu thật hoặc điều kiện production. Nếu toàn bộ pod được thay bằng phiên bản mới ngay lập tức, phạm vi ảnh hưởng của lỗi cũng tăng rất nhanh.

Progressive delivery giảm phạm vi ảnh hưởng bằng cách đưa phiên bản mới ra từng bước. Sau mỗi bước, hệ thống dừng lại để quan sát tín hiệu trước khi tiếp tục.

## Vòng lặp triển khai

```text
Deploy nhỏ -> Thu thập tín hiệu -> Đánh giá -> Promote hoặc Abort
```

Điểm khác biệt quan trọng là quyết định promote không chỉ dựa trên việc pod đã `Running`. Quyết định cần dựa trên metrics phản ánh chất lượng như error ratio, latency hoặc burn rate.

## Canary hoạt động như thế nào?

Canary giữ phiên bản ổn định tiếp tục phục vụ phần lớn traffic, đồng thời đưa một phần nhỏ traffic sang phiên bản mới.

Ví dụ:

1. Đưa 20% traffic sang phiên bản mới.
2. Chờ đủ thời gian để thu thập metrics.
3. Kiểm tra success rate và burn rate.
4. Tăng lên 50% nếu chất lượng đạt yêu cầu.
5. Promote toàn bộ hoặc abort khi phát hiện vấn đề.

## Các chiến lược liên quan

- Canary deployment.
- Blue/Green deployment.
- Feature flag.
- A/B testing.

Canary tập trung vào giảm rủi ro vận hành. A/B testing thường tập trung vào so sánh hành vi người dùng. Feature flag kiểm soát khả năng bật/tắt tính năng độc lập với việc deploy binary.

## Điều kiện để canary có ý nghĩa

- Phiên bản mới phải nhận được traffic đủ để tạo dữ liệu đánh giá.
- Metrics phải phản ánh trải nghiệm người dùng.
- Phải có tiêu chí promote và abort rõ ràng.
- Stable version cần sẵn sàng để phục vụ lại khi canary thất bại.

## Kết luận

Progressive delivery không loại bỏ lỗi release. Nó giới hạn phạm vi ảnh hưởng và tạo cơ hội phát hiện lỗi trước khi toàn bộ người dùng gặp phải.
