# Bài thực hành D3 - Canary với Argo Rollouts

## Mục tiêu

- Tạo Rollout cho demo app.
- Tạo AnalysisTemplate kiểm tra success rate và fast burn.
- Kiểm tra canary thành công.
- Kiểm tra auto-abort khi metric xấu.
- Dùng forced-failure drill khi app chưa có metrics thật.
- Tạo traffic bằng k6 để có dữ liệu đánh giá.

## Bắt đầu với Demo App W8

Demo app W8 hiện là static nginx và chưa phát metrics ứng dụng. Bắt đầu bằng bài canary thủ công:

```text
rollout/w8-demo-app-canary.yaml
rollout/w8-demo-app-canary-explained.md
```

File này sử dụng đúng image, NodePort, probes và labels của W8. Sau khi hiểu manual canary, tiếp tục với các AnalysisTemplate bên dưới để luyện auto-abort.

## Cấu trúc

```text
d3-canary/
  rollout/
    w8-demo-app-canary.yaml
    w8-demo-app-canary-explained.md
    demo-app-service.yaml
    demo-app-rollout.yaml
  analysis-template/
    prometheus-success-rate.yaml
    prometheus-fast-burn.yaml
    prometheus-forced-failure.yaml
  load-test/
    smoke.js
```

## Prerequisite

- Cluster đã cài Argo Rollouts controller và kubectl plugin.
- Prometheus hoạt động tại địa chỉ được khai báo trong AnalysisTemplate.
- Recording rule `demo_app:http_request_errors_per_requests:ratio_rate5m` từ Day B đã tồn tại.
- Demo app đã được instrument hoặc metrics đã được ánh xạ về recording rule trên.

## Bước 1 - Chuẩn bị tài nguyên

```bash
kubectl apply -f rollout/demo-app-service.yaml
kubectl apply -f analysis-template/prometheus-success-rate.yaml
kubectl apply -f analysis-template/prometheus-fast-burn.yaml
kubectl apply -f rollout/demo-app-rollout.yaml
```

## Bước 2 - Quan sát Rollout

```bash
kubectl argo rollouts get rollout demo-app -n demo --watch
kubectl get analysisrun -n demo
kubectl get rs,pods -n demo
```

## Bước 3 - Tạo traffic

```bash
kubectl port-forward svc/demo-app -n demo 8080:80
k6 run -e TARGET_URL=http://localhost:8080 load-test/smoke.js
```

## Bước 4 - Luyện good release

1. Cập nhật image sang phiên bản hoạt động bình thường.
2. Theo dõi canary tăng từ 20% lên 50%.
3. Xác nhận AnalysisRun thành công.
4. Xác nhận Rollout được promote.

## Bước 5 - Luyện auto-abort bằng metrics thật

1. Cập nhật image sang phiên bản tạo nhiều lỗi `5xx`.
2. Tiếp tục tạo traffic bằng k6.
3. Theo dõi success rate giảm hoặc fast burn vượt `0.0144`.
4. Xác nhận AnalysisRun thất bại và Rollout dừng.

## Bước 6 - Forced-failure drill

Nếu app chưa có metrics, thay một template trong Rollout bằng `demo-app-forced-failure`, sau đó apply:

```bash
kubectl apply -f analysis-template/prometheus-forced-failure.yaml
kubectl apply -f rollout/demo-app-rollout.yaml
kubectl argo rollouts get rollout demo-app -n demo --watch
```

Template dùng `vector(0)` nên analysis sẽ thất bại có chủ đích. Sau khi hoàn thành drill, đổi Rollout về template success-rate và fast-burn.

## Lệnh tham khảo

```bash
kubectl argo rollouts promote demo-app -n demo
kubectl argo rollouts abort demo-app -n demo
kubectl argo rollouts retry rollout demo-app -n demo
kubectl describe analysisrun -n demo
```

## Evidence cần lưu

- Rollout ở bước 20% và 50%.
- AnalysisRun thành công của good release.
- AnalysisRun thất bại của bad release hoặc forced-failure drill.
- Trạng thái stable/canary ReplicaSet sau khi abort.
