# Bài thực hành D3 - Canary với Argo Rollouts

## Mục tiêu

- Tạo Rollout cho demo app.
- Tạo AnalysisTemplate dùng Prometheus query.
- Kiểm tra canary thành công.
- Kiểm tra auto-abort khi metric xấu.

## Cấu trúc

```text
d3-canary/
  rollout/demo-app-rollout.yaml
  analysis-template/prometheus-success-rate.yaml
```

## Các bước thực hành

1. Cài Argo Rollouts controller.
2. Apply AnalysisTemplate.
3. Apply Rollout.
4. Theo dõi rollout bằng kubectl argo rollouts.
5. Thử deploy version tốt và quan sát promotion.
6. Thử deploy version lỗi và quan sát abort.

## Lệnh tham khảo

```bash
kubectl apply -f analysis-template/prometheus-success-rate.yaml
kubectl apply -f rollout/demo-app-rollout.yaml
kubectl argo rollouts get rollout demo-app -n demo
kubectl get analysisrun -n demo
```

