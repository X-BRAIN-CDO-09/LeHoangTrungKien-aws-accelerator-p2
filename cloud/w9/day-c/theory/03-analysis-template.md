# 03 - AnalysisTemplate với Prometheus

## Tách tiêu chí đánh giá khỏi Rollout

Rollout mô tả các bước phát hành, còn AnalysisTemplate mô tả cách quyết định phiên bản mới có đủ tốt để đi tiếp hay không. Tách hai phần này giúp cùng một tiêu chí có thể được tái sử dụng ở nhiều rollout.

Khi Rollout gọi AnalysisTemplate, Argo Rollouts tạo một `AnalysisRun`. AnalysisRun thực hiện query theo interval, lưu kết quả từng measurement và quyết định thành công, thất bại hoặc inconclusive.

## Inline và background analysis

- Inline analysis chạy tại một bước cụ thể và Rollout chờ kết quả trước khi tiếp tục.
- Background analysis chạy song song trong quá trình rollout và có thể abort rollout khi metric xấu.

Lab sử dụng inline analysis để dễ quan sát mối liên hệ giữa từng bước canary và kết quả Prometheus.

## Các trường quan trọng

- `interval`: khoảng thời gian giữa các lần đo.
- `count`: số measurement cần thực hiện.
- `successCondition`: điều kiện để measurement được tính là thành công.
- `failureCondition`: điều kiện xác định measurement thất bại.
- `failureLimit`: số lần thất bại cho phép trước khi AnalysisRun fail.
- `consecutiveSuccessLimit`: số lần thành công liên tiếp cần đạt.

Ví dụ success rate:

```yaml
successCondition: len(result) > 0 && result[0] >= 0.99
failureCondition: len(result) == 0 || result[0] < 0.99
```

Kiểm tra `len(result)` giúp xử lý trường hợp Prometheus chưa có dữ liệu thay vì truy cập trực tiếp vào phần tử không tồn tại.

## Kết nối với Burn Rate

Success rate cho biết chất lượng ngay lúc đó. Burn rate cho biết tốc độ tiêu hao error budget so với SLO. Dùng cả hai giúp canary vừa kiểm tra tình trạng hiện tại, vừa tránh promote một phiên bản đang làm SLO xấu đi nhanh.

Day C tái sử dụng recording rule từ Day B:

```promql
demo_app:http_request_errors_per_requests:ratio_rate5m
```

Với SLO 99.9%, fast burn threshold của lab là:

```text
14.4 × 0.001 = 0.0144
```

## Khi AnalysisRun thất bại

Inline analysis thất bại sẽ làm Rollout dừng và chuyển sang trạng thái degraded/aborted tùy quá trình. Stable ReplicaSet tiếp tục là lựa chọn an toàn trong khi canary không được promote.

## Kết luận

AnalysisTemplate biến metrics thành cổng kiểm soát release. Tiêu chí cần đủ nghiêm để bảo vệ người dùng, nhưng cũng cần xử lý trường hợp thiếu dữ liệu để tránh quyết định sai.
