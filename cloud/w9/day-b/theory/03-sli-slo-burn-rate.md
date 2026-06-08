# 03 - SLI, SLO và Burn Rate

## SLI

SLI là chỉ số đo chất lượng dịch vụ. Một SLI tốt nên phản ánh trải nghiệm thực tế của người dùng.

Ví dụ:

- Availability SLI = request thành công / tổng số request.
- Latency SLI = request dưới 300ms / tổng số request.

## SLO

SLO là mục tiêu chất lượng dựa trên SLI.

Ví dụ:

- 99.9% request thành công trong 30 ngày.
- 95% request có latency dưới 300ms trong 30 ngày.

## Error Budget

Error budget là phần lỗi được phép xảy ra mà vẫn không vi phạm SLO. Nếu SLO là 99.9%, hệ thống có 0.1% error budget.

## Burn Rate

Burn rate cho biết hệ thống đang tiêu hao error budget nhanh hay chậm.

- Burn rate cao: hệ thống đang lỗi nhiều, cần xử lý nhanh.
- Burn rate thấp nhưng kéo dài: có thể là lỗi âm thầm, cần theo dõi.

## Multi-window Burn Rate

Kết hợp nhiều cửa sổ thời gian giúp cảnh báo chính xác hơn:

- Fast burn: 5m và 1h.
- Slow burn: 30m và 6h.

Fast burn giúp phát hiện sự cố lớn nhanh. Slow burn giúp phát hiện lỗi kéo dài nhưng ít ồn hơn.

