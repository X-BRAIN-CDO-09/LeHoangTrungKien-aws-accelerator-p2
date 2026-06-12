# Luồng End-to-End - GitOps, Observability và Canary

Tài liệu này giải thích cách các file YAML trong `w9-lab-gitops-final` phối hợp
với nhau để triển khai và vận hành ứng dụng Flipkart theo mô hình GitOps.

Để xem giải thích chi tiết từng field trong manifest, đọc
[`YAML-LINE-BY-LINE.md`](./YAML-LINE-BY-LINE.md).

## 1. Mục tiêu hệ thống

Hệ thống hoàn chỉnh thực hiện luồng sau:

```text
Developer thay đổi manifest hoặc image tag
  -> push lên nhánh main
  -> ArgoCD phát hiện thay đổi trong Git
  -> ArgoCD đồng bộ desired state vào Kubernetes
  -> Argo Rollouts phát hành backend theo từng bước canary
  -> Load test tạo request vào canary
  -> Backend xuất metric tại /metrics
  -> Prometheus scrape và tính SLI/SLO
  -> AnalysisRun query Prometheus để đánh giá canary
  -> bản tốt được promote thành stable
  -> bản lỗi bị tự động abort
  -> Prometheus alert và Alertmanager gửi email khi SLO bị vi phạm
```

Git là **nguồn sự thật duy nhất**. Trừ bước bootstrap ban đầu, không cần dùng
`kubectl apply` để triển khai từng manifest ứng dụng.

## 2. Cấu trúc chính

```text
w9-lab-gitops-final/
├── argocd/
│   ├── root.yaml
│   └── apps/
│       ├── kube-prometheus-stack.yaml
│       ├── argo-rollouts.yaml
│       ├── backend.yaml
│       └── frontend.yaml
├── flipkart/k8s/
│   ├── backend/
│   │   ├── mongodb.yaml
│   │   ├── backend-services.yaml
│   │   ├── backend-rollout.yaml
│   │   ├── backend-servicemonitor.yaml
│   │   ├── backend-prometheus-rules.yaml
│   │   ├── backend-analysis-template.yaml
│   │   └── backend-grafana-dashboard.yaml
│   └── frontend/
│       └── frontend.yaml
├── obs-canary/load-test/
│   └── backend-canary-load.yaml
├── k8s/
│   ├── namespace.yaml
│   └── web.yaml
└── README.md
```

`flipkart/k8s/` là hệ thống Flipkart chính. Thư mục `k8s/` chỉ là bài demo
GitOps và sync waves ban đầu, hiện không có ArgoCD Application nào trỏ tới nó.

## 3. Ba lớp hoạt động của hệ thống

### Lớp 1 - GitOps control plane

```text
Git repository
  -> root Application
  -> child Applications
  -> manifest và Helm chart
  -> Kubernetes resources
```

ArgoCD liên tục so sánh trạng thái trong Git với trạng thái thật trong cluster.
Nếu có người sửa hoặc scale resource bằng tay, `selfHeal: true` sẽ đưa resource
trở lại trạng thái khai báo trong Git.

### Lớp 2 - Application runtime

```text
User
  -> flipkart-frontend Service
  -> frontend Nginx
  -> /api/* proxy tới flipkart-backend Service
  -> backend Pod
  -> flipkart-mongodb Service
  -> MongoDB Pod và PVC
```

### Lớp 3 - Observability và progressive delivery

```text
Backend /metrics
  -> ServiceMonitor
  -> Prometheus
  -> PrometheusRule + Grafana + Alertmanager
  -> AnalysisTemplate
  -> Argo Rollouts quyết định promote hoặc abort
```

## 4. Bootstrap ArgoCD và App-of-Apps

### `argocd/root.yaml`

Đây là file bootstrap quan trọng nhất và là manifest duy nhất cần apply thủ
công sau khi cài ArgoCD:

```bash
kubectl apply -f cloud/w9/w9-lab-gitops-final/argocd/root.yaml
```

`root` là ArgoCD Application mẹ. Nó theo dõi:

```text
cloud/w9/w9-lab-gitops-final/argocd/apps
```

Khi thư mục `apps/` có thêm hoặc thay đổi Application con, `root` sẽ tạo và
đồng bộ chúng. Hai cấu hình quan trọng:

- `prune: true`: xóa resource khỏi cluster khi resource bị xóa khỏi Git.
- `selfHeal: true`: sửa drift khi trạng thái trong cluster khác Git.

Đây là mẫu **App-of-Apps**: chỉ cần bootstrap `root`, sau đó toàn bộ nền tảng và
ứng dụng con được quản lý qua Git.

## 5. Các ArgoCD Application con

### `argocd/apps/kube-prometheus-stack.yaml`

Cài Helm chart `kube-prometheus-stack` vào namespace `monitoring`.

Application này cung cấp:

- Prometheus để scrape và lưu metric.
- Prometheus Operator để xử lý `ServiceMonitor` và `PrometheusRule`.
- Grafana để hiển thị dashboard.
- Alertmanager để gửi cảnh báo qua email.

Lab chạy trên Minikube nên file đã tắt nhiều component không cần thiết như
node-exporter và kube-state-metrics, đồng thời giới hạn resource và retention.

Hai cấu hình sau cho phép Prometheus đọc `ServiceMonitor` và `PrometheusRule`
do ứng dụng Flipkart tự tạo:

```yaml
serviceMonitorSelectorNilUsesHelmValues: false
ruleSelectorNilUsesHelmValues: false
```

Alertmanager dùng Gmail SMTP và đọc mật khẩu từ Kubernetes Secret
`flipkart-alertmanager-smtp`. Secret không được commit vào Git.

Sync wave của Application là `-2`, thể hiện monitoring cần được tạo sớm.

### `argocd/apps/argo-rollouts.yaml`

Cài Argo Rollouts controller và các CRD vào namespace `argo-rollouts`.

Controller này hiểu các resource đặc biệt:

- `Rollout`
- `AnalysisTemplate`
- `AnalysisRun`

Nếu không có controller và CRD này, Kubernetes không thể chạy
`backend-rollout.yaml`.

`ServerSideApply=true` được dùng vì các CRD của Argo Rollouts lớn và được quản
lý tốt hơn bằng server-side apply. `ignoreDifferences` bỏ qua các khác biệt CRD
do API server tự bổ sung.

Sync wave của Application là `-1`, sau monitoring và trước backend.

### `argocd/apps/backend.yaml`

Tạo Application `flipkart-backend` và theo dõi toàn bộ thư mục:

```text
flipkart/k8s/backend
```

Các file trong thư mục này tạo MongoDB, backend Rollout, stable/canary Service,
ServiceMonitor, Prometheus rules, AnalysisTemplate và Grafana dashboard.

Destination mặc định là namespace `flipkart`; `CreateNamespace=true` tự tạo
namespace nếu chưa tồn tại.

Sync wave của Application là `0`.

### `argocd/apps/frontend.yaml`

Tạo Application `flipkart-frontend` và theo dõi:

```text
flipkart/k8s/frontend
```

Frontend được triển khai sau backend với sync wave `1`.

## 6. Thứ tự triển khai bằng sync waves

Ở cấp Application, thứ tự mong muốn là:

```text
-2  kube-prometheus-stack
-1  argo-rollouts
 0  flipkart-backend
 1  flipkart-frontend
```

Trong Application backend, các resource tiếp tục có sync wave riêng:

```text
-2  MongoDB PersistentVolumeClaim
-1  MongoDB Deployment và Service
-1  backend stable Service và canary Service
 0  backend Rollout
 1  Grafana dashboard ConfigMap
```

Resource không khai báo annotation sync wave dùng wave `0`.

Sync waves giúp giảm lỗi thứ tự, ví dụ PVC được tạo trước MongoDB và Service
được tạo trước khi Rollout bắt đầu điều khiển stable/canary.

## 7. Các YAML của backend

### `flipkart/k8s/backend/mongodb.yaml`

File này chứa ba resource:

1. `PersistentVolumeClaim` yêu cầu `2Gi` dung lượng.
2. `Deployment` chạy một Pod MongoDB từ image `mongo:7.0`.
3. `Service` tên `flipkart-mongodb` mở port nội bộ `27017`.

Backend kết nối bằng DNS nội bộ:

```text
mongodb://flipkart-mongodb:27017/flipkart
```

PVC được mount vào `/data/db`, vì vậy dữ liệu MongoDB không mất khi Pod bị tạo
lại. MongoDB không tham gia canary vì database là thành phần stateful dùng
chung giữa các phiên bản backend.

### `flipkart/k8s/backend/backend-services.yaml`

Tạo hai Service cùng mở port `4000`:

- `flipkart-backend`: Service stable, frontend và người dùng gọi vào đây.
- `flipkart-backend-canary`: Service chỉ trỏ tới Pod canary để load test và
  AnalysisTemplate đánh giá bản mới.

Trong Git, cả hai Service có selector `app: flipkart-backend`. Khi Rollout hoạt
động, Argo Rollouts controller bổ sung selector theo ReplicaSet hash để stable
Service và canary Service trỏ đúng hai phiên bản khác nhau.

### `flipkart/k8s/backend/backend-rollout.yaml`

Thay thế Kubernetes `Deployment` thông thường bằng Argo Rollouts `Rollout`.

Rollout chạy 4 replica và khai báo:

```yaml
stableService: flipkart-backend
canaryService: flipkart-backend-canary
```

Container backend:

- Chạy image `flipkart-backend:v2-good`.
- Mở port `4000`.
- Dùng `/healthz` cho readiness và liveness probe.
- Kết nối MongoDB qua `MONGO_URI`.
- Đọc secret ứng dụng từ `flipkart-backend-secrets`.
- Dùng `APP_VERSION` để gắn nhãn version vào metric.
- Dùng `ERROR_RATE` để mô phỏng lỗi có kiểm soát.

Chiến lược canary:

```text
1. Tạo canary với weight 25%
2. Pause vô thời hạn để kiểm tra thủ công
3. Promote và tăng weight lên 50%
4. Pause 30 giây
5. Chạy AnalysisTemplate flipkart-backend-quality
6. Nếu đạt, tăng lên 100% và trở thành stable
7. Nếu không đạt, abort và giữ stable revision cũ
```

Do lab không cấu hình ingress/service-mesh traffic routing, `setWeight` được
Argo Rollouts mô phỏng bằng tỷ lệ số Pod. Với 4 replica, 25% tương ứng khoảng
1 canary Pod và 3 stable Pod.

### `flipkart/k8s/backend/backend-servicemonitor.yaml`

`ServiceMonitor` hướng dẫn Prometheus tìm các Service có label:

```yaml
app: flipkart-backend
```

Prometheus gọi endpoint `/metrics` qua port tên `http` mỗi 15 giây.

Vì stable Service và canary Service đều có label này, Prometheus scrape cả hai.
Target metadata bổ sung label `service`, nhờ đó query có thể tách:

```promql
service="flipkart-backend"
service="flipkart-backend-canary"
```

### `flipkart/k8s/backend/backend-prometheus-rules.yaml`

`PrometheusRule` tạo recording rules và alert rules.

Recording rules tính sẵn:

- Request rate.
- Error ratio theo cửa sổ 2, 5 và 15 phút.
- Success ratio 5 phút.
- P95 latency.
- Error-budget burn rate 5 và 15 phút.

SLO availability của lab là `99.5%`, tương ứng error budget `0.5%` hay `0.005`.
Burn rate được tính bằng:

```text
error ratio / 0.005
```

Alert rules:

- `FlipkartBackendFastBurn`: error ratio lớn hơn 10% trên cửa sổ 2 và 5 phút.
- `FlipkartBackendSlowBurn`: error ratio lớn hơn 3% trên cửa sổ 5 và 15 phút.
- `FlipkartBackendHighP95Latency`: p95 latency lớn hơn 500 ms.

Khi alert chuyển sang `Firing`, Alertmanager nhận alert và gửi email theo cấu
hình trong `kube-prometheus-stack.yaml`.

### `flipkart/k8s/backend/backend-analysis-template.yaml`

Đây là cổng kiểm định chất lượng của canary.

Khi Rollout đến bước `analysis`, Argo Rollouts tạo một `AnalysisRun` từ
template này và query Prometheus mỗi 30 giây.

Ba metric được kiểm tra:

| Metric | Điều kiện đạt |
|---|---|
| Canary request rate | Có ít nhất `0.1 request/giây` |
| Success rate | Lớn hơn hoặc bằng `95%` |
| P95 latency | Nhỏ hơn hoặc bằng `0.5 giây` |

Mỗi metric chạy 4 lần. Nếu số lần thất bại vượt `failureLimit: 2`,
AnalysisRun thất bại và Rollout tự động abort.

Query chỉ lọc:

```promql
service="flipkart-backend-canary"
```

Nhờ vậy quyết định promote không bị metric tốt của stable revision che lấp lỗi
của canary.

### `flipkart/k8s/backend/backend-grafana-dashboard.yaml`

Tạo ConfigMap có label:

```yaml
grafana_dashboard: "1"
```

Grafana sidecar phát hiện ConfigMap này và tự import dashboard
`Flipkart Backend - SLO and Canary`.

Dashboard hiển thị:

- Backend request rate.
- Availability SLI.
- Error ratio.
- P95 latency.
- Traffic theo version và HTTP status.
- Error-budget burn rate.

## 8. YAML của frontend

### `flipkart/k8s/frontend/frontend.yaml`

File chứa ba resource:

1. `ConfigMap` chứa cấu hình Nginx.
2. `Deployment` chạy 2 frontend Pod.
3. `Service` nội bộ mở port `80`.

Nginx phục vụ React static files và proxy tất cả request `/api/` tới:

```text
http://flipkart-backend:4000
```

Frontend luôn gọi stable Service. Khi canary chưa vượt qua AnalysisRun, người
dùng vẫn được bảo vệ bởi stable revision.

Frontend hiện dùng Deployment thông thường, chưa dùng canary.

## 9. Load-test YAML

### `obs-canary/load-test/backend-canary-load.yaml`

Tạo một BusyBox Pod chạy vòng lặp:

```text
wget flipkart-backend-canary:4000/api/v1/products
sleep 0.2 giây
```

Mục đích:

- Tạo traffic trực tiếp vào canary Service.
- Đảm bảo Prometheus có đủ mẫu metric để AnalysisTemplate đánh giá.
- Kiểm tra bản tốt và kích hoạt lỗi của bản xấu.

Nếu không có traffic canary, metric request rate không đạt điều kiện và
AnalysisRun sẽ thất bại dù ứng dụng không thực sự lỗi.

Load Pod là công cụ thử nghiệm, không phải workload production và hiện không
được ArgoCD Application quản lý.

## 10. Instrumentation bên trong backend

Các YAML observability chỉ hoạt động vì backend đã xuất metric.

`app/backend/observability/metrics.js` tạo:

- Counter `flipkart_http_requests_total`.
- Histogram `flipkart_http_request_duration_seconds`.
- Default Node.js metrics có prefix `flipkart_nodejs_`.
- Handler `/metrics`.
- Handler `/healthz`.
- Middleware inject lỗi dựa trên `ERROR_RATE`.

Mỗi HTTP metric có các label:

```text
method, route, status_code, version
```

`APP_VERSION` giúp Grafana và Prometheus phân biệt `v1`, `v2-good` và
`v2-bad`.

## 11. Flow triển khai từ đầu đến cuối

### Bước 1 - Bootstrap

1. Cài ArgoCD vào namespace `argocd`.
2. Apply `argocd/root.yaml` một lần.
3. Root Application đọc thư mục `argocd/apps/`.

### Bước 2 - Cài platform

1. Root tạo Application `kube-prometheus-stack`.
2. Prometheus, Grafana, Alertmanager và Operator được cài vào `monitoring`.
3. Root tạo Application `argo-rollouts`.
4. Argo Rollouts controller và CRD được cài vào `argo-rollouts`.

### Bước 3 - Triển khai ứng dụng

1. Backend Application đọc `flipkart/k8s/backend/`.
2. PVC, MongoDB, Service, Rollout và observability resources được tạo.
3. Frontend Application đọc `flipkart/k8s/frontend/`.
4. Nginx frontend proxy API tới stable backend Service.

### Bước 4 - Thu thập và hiển thị metric

1. Backend xử lý request và cập nhật counter/histogram.
2. ServiceMonitor giúp Prometheus tìm endpoint `/metrics`.
3. Prometheus scrape metric mỗi 15 giây.
4. PrometheusRule tạo SLI và đánh giá alert.
5. Grafana query các recording rules để vẽ dashboard.
6. Alertmanager gửi email nếu alert chuyển sang `Firing`.

### Bước 5 - Phát hành good canary

1. Build và load image `flipkart-backend:v2-good`.
2. Đổi `image` và `APP_VERSION` trong `backend-rollout.yaml`.
3. Commit và push lên Git.
4. ArgoCD sync thay đổi vào Rollout.
5. Argo Rollouts tạo canary Pod ở 25% rồi pause.
6. Chạy load Pod để tạo traffic vào canary Service.
7. Kiểm tra request rate, success rate và latency.
8. Promote để tiếp tục lên 50%.
9. AnalysisRun query Prometheus.
10. Nếu ba metric đạt yêu cầu, canary lên 100% và trở thành stable.

### Bước 6 - Thử nghiệm bad canary

1. Triển khai revision mới với `APP_VERSION=v2-bad` và `ERROR_RATE` cao.
2. Argo Rollouts tạo canary Pod.
3. Load Pod gửi request vào canary.
4. Middleware chủ động trả về HTTP 500 theo `ERROR_RATE`.
5. Prometheus ghi nhận success rate giảm và error ratio tăng.
6. AnalysisRun vượt `failureLimit`.
7. Argo Rollouts tự động abort revision lỗi.
8. Stable Service tiếp tục phục vụ revision tốt.
9. Burn-rate alert chuyển sang `Firing` và Alertmanager gửi email.

### Bước 7 - Git revert

Sau khi bad revision bị abort, Git vẫn đang chứa desired state lỗi. Cần revert
commit để Git và cluster cùng quay về revision tốt:

```bash
git revert <bad-release-commit>
git push
```

ArgoCD phát hiện revert và đồng bộ lại. Đây là bước bắt buộc để tránh lần sync
sau triển khai lại cấu hình lỗi.

## 12. Flow của một request

### Request người dùng thông thường

```text
User
  -> flipkart-frontend Service
  -> Nginx frontend Pod
  -> /api/v1/products
  -> flipkart-backend stable Service
  -> stable backend Pod
  -> flipkart-mongodb Service
  -> MongoDB Pod
```

### Request dùng để đánh giá canary

```text
backend-canary-load Pod
  -> flipkart-backend-canary Service
  -> canary backend Pod
  -> metric có label version và service
  -> Prometheus
  -> AnalysisRun
  -> promote hoặc abort
```

## 13. File demo GitOps cũ

### `k8s/namespace.yaml`

Tạo namespace `demo` ở sync wave `-1`.

### `k8s/web.yaml`

Minh họa sync waves trong một ứng dụng Nginx đơn giản:

```text
wave 0: ConfigMap web-config
wave 1: Deployment web
wave 2: Service web
```

Hai file này từng được dùng để thực hành GitOps, scale drift và self-heal.
Chúng không thuộc hệ thống Flipkart final và hiện không được Application nào
trong `argocd/apps/` theo dõi.

## 14. CI validation hiện tại

Workflow `.github/workflows/w9-gitops-validate.yml` chạy `kubeconform` khi có
Pull Request thay đổi manifest demo `k8s/` hoặc ArgoCD Application.

Hiện workflow chưa validate `flipkart/k8s/**`. Nếu muốn bảo vệ toàn bộ lab
final, nên bổ sung đường dẫn này vào trigger và lệnh validate.

Terraform workflow `.github/workflows/w9-terraform-ci.yml` là luồng riêng cho
hạ tầng W8:

- Pull Request hoặc push thay đổi `cloud/w8/lab/**`.
- GitHub Actions lấy AWS credential bằng OIDC.
- Chạy format, init, validate và plan.
- Chỉ apply trên `main` khi `ENABLE_TERRAFORM_APPLY=true`.

## 15. Những điểm cần nhớ

- `root.yaml` quản lý Application; `backend.yaml` và `frontend.yaml` quản lý
  manifest ứng dụng.
- `backend-rollout.yaml` quyết định cách phát hành; `AnalysisTemplate` quyết
  định bản mới có đủ chất lượng hay không.
- `ServiceMonitor` đưa metric vào Prometheus; `PrometheusRule` biến metric
  thành SLI, burn rate và alert.
- Stable Service phục vụ người dùng; canary Service phục vụ kiểm định bản mới.
- Load test phải chạy trong quá trình analysis để canary có dữ liệu đánh giá.
- Auto-abort bảo vệ cluster, còn `git revert` sửa lại desired state trong Git.
- MongoDB dùng PVC và không tham gia canary.
- Secret SMTP và secret ứng dụng không được commit vào repository.

## 16. Evidence

Ảnh và kết quả thực hành được tổng hợp tại:

- [`README.md`](./README.md)
- [`obs-canary/evidence/`](./obs-canary/evidence/)
