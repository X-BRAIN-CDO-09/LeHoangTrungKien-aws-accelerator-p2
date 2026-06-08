# 03 - AnalysisTemplate với Prometheus

## AnalysisTemplate là gì?

AnalysisTemplate mô tả cách Argo Rollouts đánh giá một rollout. Nó có thể dùng Prometheus query để kiểm tra metric của phiên bản mới.

## Ví dụ metric

- Success rate.
- Error rate.
- P95 latency.
- Burn rate.

## Success Condition

`successCondition` định nghĩa điều kiện metric phải đạt.

Ví dụ:

```text
result[0] >= 0.99
```

Điều này có nghĩa là success rate phải đạt ít nhất 99%.

## Failure Limit

`failureLimit` cho biết số lần metric được phép thất bại trước khi rollout bị xem là lỗi.

## Kết nối với SLO

Canary không nên chỉ kiểm tra pod có chạy hay không. Canary nên kiểm tra metric gắn với trải nghiệm người dùng như availability, latency hoặc burn rate.

