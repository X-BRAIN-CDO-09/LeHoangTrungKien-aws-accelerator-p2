# 02 - Argo Rollouts

## Vì sao cần Rollout CRD?

Kubernetes Deployment phù hợp với rolling update, nhưng không có sẵn các bước như tăng traffic theo phần trăm, pause để quan sát hoặc chạy phân tích metrics trước khi tiếp tục.

Argo Rollouts bổ sung controller và `Rollout` CRD để mô tả quy trình phát hành chi tiết hơn.

## Những thành phần Rollout quản lý

- Stable ReplicaSet: phiên bản đang phục vụ ổn định.
- Canary ReplicaSet: phiên bản mới đang được đánh giá.
- Canary steps: danh sách bước tăng weight, pause hoặc analysis.
- AnalysisRun: lần chạy kiểm tra metrics cụ thể.

## Cách đọc một chiến lược canary

```yaml
steps:
  - setWeight: 20
  - pause:
      duration: 60s
  - analysis:
      templates:
        - templateName: demo-app-success-rate
  - setWeight: 50
```

Luồng trên đưa canary lên 20%, chờ 60 giây, chạy analysis, rồi mới tăng lên 50%.

Nếu không cấu hình traffic router, Argo Rollouts phân chia theo số pod và chỉ có thể xấp xỉ phần trăm mong muốn. Ví dụ, với 5 replicas thì 20% tương ứng chính xác một canary pod. Với 3 replicas, 20% không thể chia chính xác.

## Pause, Promote và Abort

- Pause có duration: tự tiếp tục sau thời gian đã định.
- Pause không có duration: chờ thao tác promote.
- Promote: tiếp tục sang bước kế tiếp.
- Abort: dừng rollout và giữ stable version.

## Các lệnh quan sát

```bash
kubectl argo rollouts get rollout demo-app -n demo --watch
kubectl argo rollouts promote demo-app -n demo
kubectl argo rollouts abort demo-app -n demo
kubectl argo rollouts retry rollout demo-app -n demo
```

## Điểm cần phân biệt

`setWeight` không đảm bảo chia traffic chính xác nếu chỉ dựa trên số replicas. Muốn điều khiển traffic chính xác hơn cần tích hợp traffic router như NGINX Ingress, Istio hoặc một provider được hỗ trợ.

## Kết luận

Rollout CRD biến quy trình phát hành thành cấu hình declarative. Các bước canary, pause và analysis đều được lưu trong Git, phù hợp với luồng GitOps của Day A.
