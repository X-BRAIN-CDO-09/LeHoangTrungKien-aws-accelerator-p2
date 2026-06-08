# 02 - Argo Rollouts

## Argo Rollouts là gì?

Argo Rollouts là Kubernetes controller hỗ trợ progressive delivery. Nó mở rộng khả năng của Deployment truyền thống bằng các chiến lược như canary và blue/green.

## Rollout CRD

`Rollout` là custom resource dùng để mô tả cách triển khai ứng dụng. Nó có thể định nghĩa:

- Số replicas.
- Pod template.
- Canary steps.
- Pause duration.
- AnalysisTemplate.

## Canary Steps

Canary steps quyết định cách tăng traffic cho phiên bản mới.

Ví dụ:

- 20% traffic cho bản mới.
- Pause 60 giây.
- Chạy analysis.
- Tăng lên 50%.
- Chạy analysis lần nữa.
- Nếu tốt thì rollout 100%.

## Abort

Nếu analysis thất bại, rollout có thể bị abort. Điều này giúp ngăn phiên bản lỗi lan rộng đến toàn bộ người dùng.

