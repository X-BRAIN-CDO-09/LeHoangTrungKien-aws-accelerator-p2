# 03 - SLI, SLO và Burn Rate

## Bắt đầu từ trải nghiệm người dùng

SLO không nên bắt đầu từ việc CPU phải thấp hơn bao nhiêu. Người dùng quan tâm request có thành công và phản hồi có đủ nhanh hay không. Vì vậy, SLI nên đo chất lượng dịch vụ ở gần trải nghiệm người dùng nhất.

## SLI

SLI là phép đo thực tế của dịch vụ.

```text
Availability SLI = good requests / valid requests
Latency SLI      = requests nhanh hơn ngưỡng / valid requests
```

Good request cần được định nghĩa rõ. Ví dụ, HTTP `2xx`, `3xx` và một số `4xx` có thể vẫn là phản hồi hợp lệ, trong khi `5xx` thường được xem là lỗi phía dịch vụ.

## SLO

SLO đặt mục tiêu cho SLI trong một khoảng thời gian.

Ví dụ:

- Availability đạt ít nhất 99.9% trong cửa sổ 30 ngày.
- 95% request hoàn thành dưới 300ms trong cửa sổ 30 ngày.

## Error Budget

Error budget là phần không hoàn hảo được chấp nhận trong SLO.

```text
Error budget = 1 - SLO target
```

Với availability SLO là 99.9%, error budget là 0.1%. Nếu error budget bị tiêu hao quá nhanh, team cần ưu tiên độ ổn định thay vì tiếp tục release với tốc độ cũ.

## Burn Rate

Burn rate so sánh tốc độ lỗi hiện tại với tốc độ lỗi cho phép bởi SLO.

```text
Burn rate = observed error ratio / allowed error ratio
```

- Burn rate bằng `1`: error budget đang được dùng đúng tốc độ cho phép.
- Burn rate lớn hơn `1`: error budget sẽ hết sớm nếu tình trạng tiếp tục.
- Burn rate rất cao: cần phản ứng nhanh vì chất lượng đang giảm mạnh.

## Vì sao cần nhiều cửa sổ?

Chỉ dùng cửa sổ ngắn dễ tạo cảnh báo vì những spike nhỏ. Chỉ dùng cửa sổ dài lại phát hiện sự cố quá chậm. Multi-window burn-rate alert kết hợp cả hai:

- Fast burn: `5m` và `1h`, phát hiện sự cố lớn đang diễn ra.
- Slow burn: `30m` và `6h`, phát hiện lỗi nhỏ nhưng kéo dài.

Hai cửa sổ trong cùng một cảnh báo phải cùng vượt ngưỡng. Cách này giảm nhiễu nhưng vẫn phát hiện được sự cố có ảnh hưởng thật.

## Ngưỡng dùng trong lab

Lab giả định availability SLO là `99.9%`, tương ứng error budget `0.001`.

- Fast burn sử dụng hệ số `14.4`.
- Slow burn sử dụng hệ số `6`.

Ngưỡng error ratio được tính bằng `burn-rate factor × error budget`.

## Ghi nhớ

Alert tốt nên dựa trên triệu chứng người dùng đang gặp phải, chẳng hạn error rate hoặc latency cao. Việc alert trên SLO burn rate giúp cảnh báo gắn với mức độ ảnh hưởng thay vì chỉ báo từng thay đổi kỹ thuật nhỏ.
