# Ngày C - Progressive Delivery và Canary

## Mục tiêu

- Hiểu progressive delivery và lý do canary an toàn hơn so với deploy toàn bộ cùng lúc.
- Nắm các khái niệm chính của Argo Rollouts:
  - Rollout CRD
  - Các bước canary
  - AnalysisTemplate
  - Điều kiện abort
- Kết nối rollout analysis với Prometheus metrics và tư duy burn rate.

## Luồng Canary

1. Đưa một phần nhỏ traffic sang phiên bản mới.
2. Query Prometheus để kiểm tra success rate hoặc latency.
3. Tăng traffic dần nếu metrics vẫn tốt.
4. Tự động abort và rollback nếu metrics xấu.

## Checklist thực hành

- [ ] Cài Argo Rollouts controller.
- [ ] Chuyển Deployment sang Rollout.
- [ ] Tạo Service cho demo app.
- [ ] Thêm AnalysisTemplate dùng Prometheus query.
- [ ] Kết nối analysis với recording rule từ Day B.
- [ ] Test canary thành công.
- [ ] Test canary thất bại và xác nhận auto-abort.
- [ ] Ghi lại AnalysisRun và Rollout status làm evidence.

## Nội dung theory

- `01-progressive-delivery.md`: vòng lặp deploy, quan sát và quyết định.
- `02-argo-rollouts.md`: Rollout CRD, ReplicaSet, weight, pause, promote và abort.
- `03-analysis-template.md`: AnalysisRun, Prometheus query và điều kiện đánh giá.
- `04-canary-guardrails.md`: guardrails, good/bad release và forced-failure drill.

## Prerequisite từ Day B

Demo app W8 hiện là static nginx và chưa tự phát metric `http_requests_total`. Để chạy analysis thật, cần instrument ứng dụng hoặc cung cấp metric tương đương, sau đó cập nhật Prometheus query cho đúng tên metric và labels.

## Cấu trúc thư mục

```text
day-c/
  theory/      # Ghi chú lý thuyết progressive delivery và canary
  exercises/   # Bài thực hành Rollout và AnalysisTemplate
```
