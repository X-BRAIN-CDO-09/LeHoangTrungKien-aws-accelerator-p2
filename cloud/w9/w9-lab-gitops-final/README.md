# W9 Final - GitOps, Observability và Canary

Thư mục này lưu bằng chứng hoàn thành lab GitOps, Observability và Progressive Delivery.
Các ảnh gốc trong `C:\Users\Admin\Pictures\Screenshots` được giữ nguyên; bản sao trong thư mục này đã được đổi tên theo nội dung để thuận tiện khi trình bày.

## Kết quả chính

| Trạng thái | Evidence | Nội dung chứng minh |
|---|---|---|
| [x] | `01-argocd-applications-healthy.png` | ArgoCD quản lý `root`, backend, frontend, Prometheus và Argo Rollouts ở trạng thái `Synced/Healthy`. |
| [x] | `02-prometheus-monitoring-targets-up.png` | Prometheus hoạt động và các scrape target của monitoring stack hiển thị `UP`. |
| [x] | `03-prometheus-sli-request-rate.png`, `03a-prometheus-sli-error-ratio.png`, `03b-prometheus-sli-success-ratio.png`, `03c-prometheus-sli-p95-latency.png` | Các SLI traffic, error ratio, success ratio và p95 latency đã có dữ liệu. |
| [x] | `04-slo-alert-firing.png` | Hai alert `FlipkartBackendFastBurn` và `FlipkartBackendSlowBurn` chuyển sang `Firing`. |
| [x] | `05-alertmanager-email-received.jpg` | Alertmanager gửi email cảnh báo thành công. |
| [x] | `06-manual-canary-paused-25.png` | Rollout dừng tại bước manual pause với 25% canary. |
| [x] | `07-good-release-analysis-success.png` | `v2-good` đạt 100%, AnalysisRun thành công và trở thành stable revision. |
| [x] | `08-bad-release-auto-abort.png` | AnalysisRun phát hiện success rate không đạt và tự động abort revision lỗi. |
| [x] | `10-grafana-slo-canary-dashboard.png` | Dashboard Grafana hiển thị request rate, availability, error ratio, p95 latency, traffic theo version và burn rate. |
| [x] | `11-rollout-resource-tree-auto-abort.png` | Resource tree thể hiện stable/canary ReplicaSet, Pod và AnalysisRun thất bại. |

## Luồng evidence

### 1. GitOps và drift reconciliation

- `28-manual-scale-drift-created.png`: tạo drift bằng cách scale Deployment thủ công.
- `29-gitops-drift-reconciled.png`: số replica được controller đưa dần về desired state.
- `30-deployment-returned-to-desired-replicas.png`: Deployment trở lại đúng 2 replica.
- `01-argocd-applications-healthy.png`: toàn bộ Application cuối cùng `Synced/Healthy`.

#### Kết quả ArgoCD

![Các ArgoCD Application đều Synced và Healthy](./obs-canary/evidence/01-argocd-applications-healthy.png)

<details>
<summary>Xem quá trình tạo drift và tự động reconciliation</summary>

**Tạo drift bằng cách scale thủ công:**

![Tạo drift bằng cách scale thủ công](./obs-canary/evidence/28-manual-scale-drift-created.png)

**GitOps controller đưa số replica về desired state:**

![GitOps tự động reconcile drift](./obs-canary/evidence/29-gitops-drift-reconciled.png)

**Deployment trở lại đúng số replica khai báo trong Git:**

![Deployment trở lại desired replicas](./obs-canary/evidence/30-deployment-returned-to-desired-replicas.png)

</details>

### 2. Metrics và SLI

- `13-backend-healthz-and-metrics.png`: backend trả về `/healthz` và xuất Prometheus metrics tại `/metrics`.
- `14-prometheus-http-request-metric.png`: Prometheus nhận metric `flipkart_http_requests_total`.
- `15-prometheus-total-request-rate.png`: tốc độ request tổng hợp từ counter.
- `03-prometheus-sli-request-rate.png`: recording rule request rate.
- `03a-prometheus-sli-error-ratio.png`: error ratio ở trạng thái bình thường bằng `0`.
- `03b-prometheus-sli-success-ratio.png`: success ratio ở trạng thái bình thường bằng `1`.
- `03c-prometheus-sli-p95-latency.png`: p95 latency khoảng `47.5 ms`.

PromQL tiêu biểu:

```promql
flipkart_backend:http_requests:rate2m
flipkart_backend:http_errors:ratio_rate5m
flipkart_backend:http_success:ratio_rate5m
flipkart_backend:http_request_duration:p95_rate5m
```

#### Backend metrics và Prometheus target

![Backend healthz và metrics](./obs-canary/evidence/13-backend-healthz-and-metrics.png)

> Ảnh target bên dưới chứng minh Prometheus stack đang hoạt động và scrape target thành công. Metric `flipkart_http_requests_total` ở ảnh tiếp theo chứng minh Prometheus cũng đã thu thập dữ liệu từ backend.

![Prometheus monitoring targets UP](./obs-canary/evidence/02-prometheus-monitoring-targets-up.png)

#### Các chỉ số SLI

| Request rate | Error ratio |
|---|---|
| ![Backend request rate](./obs-canary/evidence/03-prometheus-sli-request-rate.png) | ![Backend error ratio](./obs-canary/evidence/03a-prometheus-sli-error-ratio.png) |

| Success ratio | P95 latency |
|---|---|
| ![Backend success ratio](./obs-canary/evidence/03b-prometheus-sli-success-ratio.png) | ![Backend p95 latency](./obs-canary/evidence/03c-prometheus-sli-p95-latency.png) |

<details>
<summary>Xem metric HTTP và request rate ban đầu</summary>

![Prometheus nhận HTTP request metric](./obs-canary/evidence/14-prometheus-http-request-metric.png)

![Prometheus tổng hợp request rate](./obs-canary/evidence/15-prometheus-total-request-rate.png)

</details>

### 3. SLO và burn-rate alert

- `16-injected-error-ratio-5m.png`: error ratio 5 phút tăng sau khi inject lỗi.
- `17-injected-error-ratio-2m.png`: error ratio 2 phút tăng lên khoảng `0.5`.
- `04-slo-alert-firing.png`: fast-burn và slow-burn alert cùng chuyển sang `Firing`.
- `05-alertmanager-email-received.jpg`: email cảnh báo được gửi tới người nhận.
- `10-grafana-slo-canary-dashboard.png`: dashboard thể hiện traffic và error-budget burn rate trong quá trình thử nghiệm.

#### Error ratio tăng và alert chuyển sang Firing

| Error ratio 5 phút | Error ratio 2 phút |
|---|---|
| ![Injected error ratio 5m](./obs-canary/evidence/16-injected-error-ratio-5m.png) | ![Injected error ratio 2m](./obs-canary/evidence/17-injected-error-ratio-2m.png) |

![Fast burn và slow burn alert firing](./obs-canary/evidence/04-slo-alert-firing.png)

#### Email từ Alertmanager

<p align="center">
  <img src="./obs-canary/evidence/05-alertmanager-email-received.jpg" alt="Email cảnh báo từ Alertmanager" width="420">
</p>

#### Grafana SLO và Canary Dashboard

![Grafana SLO và Canary dashboard](./obs-canary/evidence/10-grafana-slo-canary-dashboard.png)

### 4. Good canary release

- `06-manual-canary-paused-25.png`: `v2-good` chạy ở 25% để kiểm tra thủ công.
- `18-canary-service-request-rate.png`: canary service nhận traffic.
- `19-canary-success-rate.png`: canary success rate bằng `1`.
- `20-good-release-manual-promote.png`: thực hiện promote sau khi kiểm tra.
- `21-good-release-paused-50.png`: rollout tiếp tục tới 50%.
- `22-good-release-analysis-running.png`: AnalysisRun đang đánh giá metric.
- `23-good-release-analysis-finished.png`: AnalysisRun hoàn tất thành công.
- `07-good-release-analysis-success.png`: `v2-good` trở thành stable với 4/4 Pod sẵn sàng.

Commit triển khai good release:

```text
b562e28 [W9-lab] deploy good backend canary
```

#### Canary dừng ở 25% để kiểm tra

![Good release paused at 25 percent](./obs-canary/evidence/06-manual-canary-paused-25.png)

| Canary request rate | Canary success rate |
|---|---|
| ![Canary service request rate](./obs-canary/evidence/18-canary-service-request-rate.png) | ![Canary success rate](./obs-canary/evidence/19-canary-success-rate.png) |

#### Good release hoàn tất

![Good release AnalysisRun successful và trở thành stable](./obs-canary/evidence/07-good-release-analysis-success.png)

<details>
<summary>Xem từng bước promote và AnalysisRun của good release</summary>

![Promote good release](./obs-canary/evidence/20-good-release-manual-promote.png)

![Good release paused at 50 percent](./obs-canary/evidence/21-good-release-paused-50.png)

![Good release AnalysisRun running](./obs-canary/evidence/22-good-release-analysis-running.png)

![Good release AnalysisRun finished](./obs-canary/evidence/23-good-release-analysis-finished.png)

</details>

### 5. Bad canary và tự động abort

- `24-bad-release-paused-25.png`: revision lỗi bắt đầu ở 25%.
- `25-bad-release-progressing-50.png`: revision lỗi tiến tới bước 50%.
- `26-bad-release-paused-50.png`: rollout dừng tại 50%.
- `27-bad-release-analysis-failing.png`: AnalysisRun bắt đầu ghi nhận các lần đánh giá thất bại.
- `08-bad-release-auto-abort.png`: rollout bị abort vì metric `success-rate` vượt `failureLimit`.
- `11-rollout-resource-tree-auto-abort.png`: cây tài nguyên thể hiện revision lỗi bị thu hồi và stable revision vẫn phục vụ.

Commit triển khai và revert bad release:

```text
5d9b70c [W9-lab] deploy bad backend canary
2186f8d Revert "[W9-lab] deploy bad backend canary"
```

#### AnalysisRun tự động abort bad release

![Bad release bị tự động abort](./obs-canary/evidence/08-bad-release-auto-abort.png)

![Resource tree sau khi tự động abort](./obs-canary/evidence/11-rollout-resource-tree-auto-abort.png)

<details>
<summary>Xem diễn biến bad canary trước khi abort</summary>

![Bad release paused at 25 percent](./obs-canary/evidence/24-bad-release-paused-25.png)

![Bad release progressing to 50 percent](./obs-canary/evidence/25-bad-release-progressing-50.png)

![Bad release paused at 50 percent](./obs-canary/evidence/26-bad-release-paused-50.png)

![Bad release AnalysisRun failing](./obs-canary/evidence/27-bad-release-analysis-failing.png)

</details>

### 6. Phục hồi sau sự cố

- `09-git-revert-created-and-pushed.png`: tạo và push revert commit.
- `12-argocd-recovery-synced-healthy.png`: ArgoCD chuyển từ `Degraded/OutOfSync` về `Synced/Healthy`.

#### Git revert và ArgoCD phục hồi

![Git revert được tạo và push](./obs-canary/evidence/09-git-revert-created-and-pushed.png)

![ArgoCD phục hồi về Synced Healthy](./obs-canary/evidence/12-argocd-recovery-synced-healthy.png)
