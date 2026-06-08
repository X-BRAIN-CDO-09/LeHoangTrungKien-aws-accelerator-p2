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
- [ ] Thêm AnalysisTemplate dùng Prometheus query.
- [ ] Test canary thành công.
- [ ] Test canary thất bại và xác nhận auto-abort.

## Cấu trúc thư mục

```text
day-c/
  theory/      # Ghi chú lý thuyết progressive delivery và canary
  exercises/   # Bài thực hành Rollout và AnalysisTemplate
```
