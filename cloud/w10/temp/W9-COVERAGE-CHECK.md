# W9 Coverage Check for Temp Repo

File này đối chiếu repo `temp` với W9 final để biết phần nào đã có, phần nào còn thiếu nếu muốn temp thay thế W9 làm nền cho W10.

## Đã có trong temp

| W9 capability | Temp hiện tại | Ghi chú |
|---|---|---|
| App of Apps | Có | `argocd/root.yaml` đọc `argocd/apps`. |
| ArgoCD child apps | Có | `app-common`, `app-api`, `app-analysis`, `app-alert`, `k8s-prometheus`, `k8s-rollout`. |
| Namespace app | Có | `app-common/demo-namespace.yaml` tạo namespace `demo`. |
| Argo Rollouts | Có | `app-api/rollout.yaml` dùng canary 10% -> 50% -> 100%. |
| AnalysisTemplate | Có | `app-analysis/analysis-template.yaml` kiểm tra success rate. |
| Prometheus stack | Có | `argocd/apps/k8s-prometheus.yaml`. |
| ServiceMonitor | Có | `app-api/servicemonitor.yaml`. |
| Alert rule | Có | `app-alert/prometheus-rules.yaml` có `SLOViolation`. |
| Security W10 morning | Có | `security-rbac-admission/` có RBAC, workload identity và Gatekeeper policies. |

## Thiếu hoặc yếu hơn W9 final

| W9 final có | Temp đang thiếu/yếu | Nên bổ sung nếu cần evidence như W9 |
|---|---|---|
| Stable service và canary service riêng | Temp chỉ có một `Service` tên `api` | Thêm `api-stable` và `api-canary`, rồi cấu hình `stableService`/`canaryService` trong Rollout. |
| Canary metric riêng theo service canary | Analysis chỉ dùng success rate tổng | Thêm metric request-rate/success-rate/p95 cho canary service. |
| AnalysisTemplate nhiều metric | Temp chỉ có success rate | Thêm request rate và p95 latency để giống W9. |
| Recording rules chi tiết | Temp chỉ có `api:success_rate:5m` | Thêm request rate, error ratio 2m/5m/15m, p95 latency, burn-rate. |
| Fast-burn / slow-burn alerts | Temp chỉ có một alert SLO đơn giản | Thêm fast-burn và slow-burn như W9. |
| Grafana dashboard manifest | Temp chưa có dashboard | Thêm ConfigMap dashboard cho API SLO/canary. |
| Load test manifest | Temp chưa có load-test job/pod | Thêm `load-test/api-canary-load.yaml`. |
| Evidence checklist/screenshots | Temp chưa có folder evidence | Thêm `evidence/README.md` hoặc checklist để lưu kết quả. |
| MongoDB/frontend app | Temp là API demo nhỏ | Không bắt buộc nếu mục tiêu là W10 RBAC/Admission, nhưng không tương đương Flipkart full stack. |

## Kết luận

Temp repo đủ để làm W10 morning RBAC + Admission vì nó có app API, GitOps, Rollout, Prometheus và Gatekeeper.

Nếu muốn temp thay thế W9 final cho toàn bộ mini-platform end-to-end, nên bổ sung thêm:

1. `stableService` và `canaryService` cho Rollout `api`.
2. AnalysisTemplate nhiều metric: request rate, success rate, p95 latency.
3. Prometheus recording rules + fast/slow burn alerts.
4. Grafana dashboard manifest.
5. Load-test manifest.
6. Evidence checklist.

