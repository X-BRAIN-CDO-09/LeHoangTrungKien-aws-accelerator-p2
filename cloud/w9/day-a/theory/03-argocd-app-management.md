# 03 - Quản lý ứng dụng nhiều tầng với ArgoCD

## Vấn đề khi cluster có nhiều thành phần

Ban đầu, một cluster có thể chỉ có một ứng dụng demo. Nhưng khi hệ thống lớn hơn, cluster thường có thêm ingress controller, monitoring, logging, cert-manager, rollout controller và nhiều service khác.

Nếu mỗi thành phần đều được tạo thủ công trên ArgoCD UI, việc quản lý sẽ nhanh chóng rối. Người mới vào team cũng khó biết cluster đang được bootstrap từ đâu và app nào phụ thuộc app nào.

## Application là đơn vị quản lý

Trong ArgoCD, `Application` giống như một bản khai báo triển khai. Nó nói cho ArgoCD biết:

- Lấy manifest từ repository nào.
- Theo dõi branch hoặc revision nào.
- Đọc manifest ở thư mục nào.
- Apply vào cluster và namespace nào.
- Có tự động sync, prune hoặc self-heal hay không.

Nhờ đó, cấu hình triển khai của ứng dụng cũng trở thành code.

## App of Apps

App of Apps là cách dùng một root application để quản lý danh sách application con. Root application không trực tiếp deploy business app, mà deploy các file `Application` khác.

Luồng có thể hình dung như sau:

```text
Root App -> apps/observability.yaml -> Prometheus/Grafana/Loki
         -> apps/demo-app.yaml      -> Demo application
         -> apps/rollouts.yaml      -> Argo Rollouts
```

Khi muốn thêm thành phần mới, chỉ cần thêm một file Application mới vào Git. Root app sync lại và ArgoCD sẽ tạo app con tương ứng.

## Khi nào cần App of Apps?

- Namespace và cấu hình nền tảng.
- Ingress controller.
- Cert-manager.
- Prometheus, Grafana, Loki.
- Argo Rollouts.
- Demo app.
- Alert rules.

Với cấu trúc này, repository giống như bản đồ của cluster. Nhìn vào thư mục app là biết cluster đang có những thành phần nào.

## Sync Waves

Không phải tài nguyên nào cũng apply được cùng lúc. Ví dụ, CRD phải tồn tại trước khi apply resource dùng CRD đó. Namespace cũng nên có trước Deployment hoặc Service.

Sync wave giúp ArgoCD apply theo thứ tự có chủ đích:

- Wave âm hoặc 0: namespace, CRD, thành phần nền tảng.
- Wave 5: controller như Argo Rollouts hoặc monitoring operator.
- Wave 10: application chính.
- Wave 20: rules, dashboard hoặc thành phần phụ thuộc app.

Cách khai báo:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "10"
```

## Ba tùy chọn cần hiểu

- Automated sync: khi Git đổi, ArgoCD tự sync mà không cần bấm tay.
- Prune: nếu manifest bị xóa khỏi Git, tài nguyên tương ứng trong cluster cũng bị xóa.
- Self-heal: nếu ai đó sửa tay trong cluster, ArgoCD tự đưa về đúng manifest trong Git.

## Các trạng thái cần quan sát

- `Synced`: actual state đã khớp desired state.
- `OutOfSync`: cluster và Git đang lệch nhau.
- `Healthy`: tài nguyên đang hoạt động bình thường.
- `Progressing`: tài nguyên đang được cập nhật hoặc chờ ổn định.
- `Degraded`: tài nguyên có lỗi cần kiểm tra.

## Kết luận

App of Apps giúp biến ArgoCD configuration thành code và quản lý nhiều application có hệ thống hơn. Sync waves giúp tránh lỗi thứ tự khi các tài nguyên có phụ thuộc lẫn nhau.
