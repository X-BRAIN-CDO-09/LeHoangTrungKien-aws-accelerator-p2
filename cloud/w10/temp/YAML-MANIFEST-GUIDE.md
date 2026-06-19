# W10 YAML Manifest Guide

Tài liệu này giải thích các file YAML trong W10 temp theo 3 phần:

- Lab sáng: RBAC + Gatekeeper Admission.
- Lab chiều: External Secrets + GHCR pull secret + Trivy/Cosign/Sigstore.
- Challenge: Payments tenant.

Repo hiện có nhiều file YAML lặp cùng pattern. Vì vậy phần "giải thích từng line" được chia thành:

1. Luồng chạy giữa các file.
2. Thống kê từng file YAML và file đó làm gì.
3. Giải thích line/pattern quan trọng theo từng loại manifest.
4. Giải thích chi tiết các file quan trọng nhất.

## 0. Thuật ngữ cơ bản cho người mới

### Cluster

Cluster là "ngôi nhà lớn" chứa toàn bộ Kubernetes. Trong lab này cluster đang chạy bằng minikube profile `w9`, nhưng tên cluster không quyết định app nào chạy bên trong. App chạy gì là do manifest và ArgoCD quyết định.

### Namespace

Namespace giống như một "căn phòng" bên trong cluster. Mỗi phòng chứa một nhóm tài nguyên riêng.

| Namespace | Ý nghĩa trong lab |
| --- | --- |
| `argocd` | Phòng điều khiển GitOps. ArgoCD sống ở đây và kéo manifest từ Git về cluster. |
| `demo` | Phòng app chính của lab. API, secret consumer, RBAC demo chạy ở đây. |
| `payments` | Phòng riêng của team Payments trong challenge. Có RBAC, quota, NetworkPolicy riêng để cô lập với `demo`. |
| `gatekeeper-system` | Phòng chứa OPA Gatekeeper controller. Nó kiểm tra manifest trước khi Kubernetes nhận. |
| `external-secrets` | Phòng chứa External Secrets Operator. Nó đồng bộ secret từ AWS Secrets Manager về Kubernetes. |
| `cosign-system` | Phòng chứa Sigstore Policy Controller. Nó kiểm tra chữ ký image trước khi Pod chạy. |
| `monitoring` | Phòng quan sát. Prometheus/Grafana/Alertmanager nằm ở đây để scrape metrics và alert. |

Ví dụ:

```yaml
metadata:
  namespace: payments
```

Nghĩa là resource này thuộc phòng `payments`. Nếu RBAC chỉ cấp quyền trong `payments`, người đó không thể tự động thao tác sang `demo`.

### GitOps

GitOps nghĩa là Git là nguồn sự thật. Mình không deploy app bằng tay lâu dài. Mình commit YAML lên Git, ArgoCD nhìn Git rồi sync cluster theo Git.

Luồng đơn giản:

```text
YAML trong Git
  -> ArgoCD đọc
  -> ArgoCD apply vào Kubernetes
  -> Cluster chạy đúng như Git
```

### ArgoCD Application

`Application` là object của ArgoCD, nói cho ArgoCD biết:

- kéo repo nào,
- đọc folder nào,
- deploy vào namespace nào,
- có auto-sync hay không.

### App of Apps

App of Apps nghĩa là có một app root quản lý nhiều child apps.

Trong lab:

```text
argocd/root.yaml
  -> đọc argocd/apps/
  -> tạo app-api, gatekeeper, eso, payments...
```

Mình chỉ cần bootstrap root một lần, các app con sẽ do root quản lý.

### sync-wave

`sync-wave` là thứ tự triển khai của ArgoCD. Số nhỏ chạy trước, số lớn chạy sau.

Ví dụ:

```yaml
annotations:
  argocd.argoproj.io/sync-wave: "6"
```

Nghĩa là app này chạy sau wave `5`, `4`, `2`, `1`, `-1`.

Vì sao cần sync-wave:

- Phải cài Gatekeeper trước rồi mới apply Constraint.
- Phải tạo namespace trước rồi mới deploy app vào namespace đó.
- Phải có External Secrets Operator trước rồi mới tạo ExternalSecret.

### CRD

CRD là Custom Resource Definition. Kubernetes mặc định không biết `Application`, `Rollout`, `ExternalSecret`, `ConstraintTemplate`, `ClusterImagePolicy`. Các controller như ArgoCD, Argo Rollouts, ESO, Gatekeeper, Sigstore cài CRD để Kubernetes hiểu các kind mới đó.

Ví dụ:

```yaml
kind: ExternalSecret
```

Kubernetes chỉ hiểu kind này sau khi External Secrets Operator được cài.

### Controller

Controller là tiến trình chạy trong cluster, liên tục quan sát resource và làm cho trạng thái thật khớp trạng thái mong muốn.

Ví dụ:

- ArgoCD controller đọc `Application`.
- Deployment controller đọc `Deployment`.
- Argo Rollouts controller đọc `Rollout`.
- ESO controller đọc `ExternalSecret`.
- Gatekeeper controller đọc `ConstraintTemplate` và `Constraint`.

### RBAC

RBAC trả lời câu hỏi: "Ai được làm gì, trên tài nguyên nào, ở phạm vi nào?"

Các mảnh chính:

- `ServiceAccount`: identity dùng trong cluster.
- `Role`: quyền trong một namespace.
- `ClusterRole`: quyền cấp toàn cluster hoặc quyền có thể bind lại.
- `RoleBinding`: gắn Role/ClusterRole cho một subject trong namespace.
- `ClusterRoleBinding`: gắn quyền toàn cluster.

Trong lab này `alice`, `bob`, `carol` là Kubernetes User được giả lập bằng impersonation `--as`. GitOps không tạo object User, chỉ tạo RBAC binding tới tên user đó.

### Admission Control

Admission là cửa kiểm tra trước khi Kubernetes nhận object. Nếu manifest vi phạm policy, nó bị reject trước khi tạo resource.

Trong lab:

- Gatekeeper kiểm manifest có an toàn không.
- Sigstore Policy Controller kiểm image có chữ ký hợp lệ không.

### ConstraintTemplate và Constraint

Với Gatekeeper:

- `ConstraintTemplate`: viết luật bằng Rego, giống định nghĩa "loại kiểm tra".
- `Constraint`: bật luật đó lên namespace/kind cụ thể, truyền tham số nếu cần.

Ví dụ dễ hiểu:

```text
ConstraintTemplate = định nghĩa luật "image phải thuộc registry được duyệt"
Constraint = áp luật đó vào Pod trong namespace demo và payments
```

### ESO, SecretStore, ExternalSecret

ESO là External Secrets Operator.

- `SecretStore`: cách kết nối tới nơi chứa secret, ví dụ AWS Secrets Manager.
- `ExternalSecret`: lấy secret nào từ AWS và tạo Kubernetes Secret tên gì.
- `Kubernetes Secret`: bản secret cuối cùng mà Pod dùng.

Luồng:

```text
AWS Secrets Manager
  -> SecretStore/ClusterSecretStore
  -> ExternalSecret
  -> Kubernetes Secret
  -> Pod mount hoặc imagePullSecrets
```

### Cosign và ClusterImagePolicy

Cosign dùng để ký image. Sigstore Policy Controller dùng public key để verify.

Luồng:

```text
GitHub Actions build image
  -> Trivy scan
  -> Cosign sign image
  -> push GHCR
  -> Kubernetes tạo Pod
  -> ClusterImagePolicy verify signature
  -> image hợp lệ mới được chạy
```

### ResourceQuota và LimitRange

- `ResourceQuota`: giới hạn tổng tài nguyên của namespace.
- `LimitRange`: đặt default request/limit cho container nếu dev quên khai báo.

Ví dụ:

```text
payments chỉ được dùng tối đa 10 pods, 2 CPU limit, 2Gi memory limit.
```

### NetworkPolicy

NetworkPolicy là firewall ở tầng Pod.

- Không có NetworkPolicy: Pod thường gọi qua lại được.
- Có default deny: chặn traffic mặc định.
- Có allow rule: chỉ mở đúng đường cần thiết.

Lưu ý: NetworkPolicy chỉ hoạt động nếu CNI hỗ trợ, ví dụ Calico.

## 1. Luồng chạy tổng thể

```text
kubectl apply -f cloud/w10/temp/argocd/root.yaml
  |
  v
ArgoCD root Application
  |
  |-- đọc folder cloud/w10/temp/argocd/apps
  |
  |-- app-common
  |     -> tạo namespace demo
  |
  |-- k8s-rollout
  |     -> cài Argo Rollouts controller và CRD Rollout
  |
  |-- k8s-prometheus
  |     -> cài Prometheus stack để có ServiceMonitor/Analysis metric
  |
  |-- gatekeeper
  |     -> cài OPA Gatekeeper controller và CRD ConstraintTemplate/Constraint
  |
  |-- security-rbac
  |     -> tạo alice/bob/carol + Role/ClusterRole demo
  |
  |-- security-workload-identity
  |     -> tạo serviceAccount api và quyền pod-reader cho workload api
  |
  |-- security-gatekeeper-templates
  |     -> tạo ConstraintTemplate bằng Rego
  |
  |-- security-gatekeeper-constraints
  |     -> bật rules Gatekeeper cho namespace demo và payments
  |
  |-- app-analysis
  |     -> tạo AnalysisTemplate cho canary
  |
  |-- app-api
  |     -> tạo Rollout api + Service + ServiceMonitor
  |
  |-- app-alert
  |     -> tạo PrometheusRule cho alert
  |
  |-- eso
  |     -> cài External Secrets Operator
  |
  |-- eso-config
  |     -> tạo SecretStore/ExternalSecret/secret-consumer/GHCR pull secret
  |
  |-- policy-controller
  |     -> cài Sigstore Policy Controller
  |
  |-- supply-chain-policies
  |     -> tạo ClusterImagePolicy verify chữ ký image
  |
  |-- payments
  |     -> tạo namespace/RBAC/quota/netpol/GHCR pull secret cho tenant payments
  |
  |-- payments-app
        -> deploy workload team Payments
```

## 2. Thứ tự sync theo ArgoCD

Các file trong `argocd/apps/*.yaml` là child Application. Mỗi file có `argocd.argoproj.io/sync-wave` để điều khiển thứ tự.

```text
Wave -2:
  app-common

Wave -1:
  k8s-rollout
  k8s-prometheus
  gatekeeper
  eso
  policy-controller

Wave 1:
  security-rbac
  security-workload-identity
  security-gatekeeper-templates
  app-analysis
  app-alert

Wave 2:
  security-gatekeeper-constraints
  eso-config
  app-api

Wave 4:
  supply-chain-policies

Wave 5:
  payments

Wave 6:
  payments-app
```

Lý do:

- Controller/CRD phải có trước resource custom.
- Namespace phải có trước workload.
- ConstraintTemplate phải có trước Constraint.
- SecretStore/ExternalSecret phải có trước Pod cần secret.
- Tenant payments phải có trước workload payments.

## 3. Thống kê YAML theo folder

### 3.1. ArgoCD App of Apps

| File | Làm gì |
| --- | --- |
| `argocd/root.yaml` | Root Application. Chỉ cần apply file này bằng tay, ArgoCD sẽ đọc toàn bộ child apps trong `argocd/apps`. |
| `argocd/apps/app-common.yaml` | Child app sync namespace/common resources ở `app-common`. |
| `argocd/apps/k8s-rollout.yaml` | Child app cài Argo Rollouts bằng Helm chart. |
| `argocd/apps/k8s-prometheus.yaml` | Child app cài kube-prometheus-stack bằng Helm chart. |
| `argocd/apps/gatekeeper.yaml` | Child app cài Gatekeeper bằng Helm chart. |
| `argocd/apps/security-rbac.yaml` | Child app sync RBAC demo: alice/bob/carol. |
| `argocd/apps/security-workload-identity.yaml` | Child app sync ServiceAccount và quyền cho workload api. |
| `argocd/apps/security-gatekeeper-templates.yaml` | Child app sync ConstraintTemplate Rego. |
| `argocd/apps/security-gatekeeper-constraints.yaml` | Child app sync Constraint enforce/warn. Hiện trỏ `constraints`, tức deny thật. |
| `argocd/apps/app-analysis.yaml` | Child app sync AnalysisTemplate cho canary. |
| `argocd/apps/app-api.yaml` | Child app sync Rollout api, Service, ServiceMonitor. |
| `argocd/apps/app-alert.yaml` | Child app sync PrometheusRule. |
| `argocd/apps/eso.yaml` | Child app cài External Secrets Operator bằng Helm chart. |
| `argocd/apps/eso-config.yaml` | Child app sync SecretStore, ExternalSecret, secret consumer. |
| `argocd/apps/policy-controller.yaml` | Child app cài Sigstore Policy Controller bằng Helm chart. |
| `argocd/apps/policies.yaml` | Child app sync ClusterImagePolicy. |
| `argocd/apps/payments.yaml` | Child app sync hạ tầng tenant payments. |
| `argocd/apps/payments-app.yaml` | Child app sync workload team Payments. |

### 3.2. App common

| File | Làm gì |
| --- | --- |
| `app-common/demo-namespace.yaml` | Tạo namespace `demo`, gắn label owner và label `policy.sigstore.dev/include=true` để Sigstore policy áp vào namespace này. |

### 3.3. API Rollout

| File | Làm gì |
| --- | --- |
| `app-api/rollout.yaml` | Tạo Argo Rollout `api`, chạy image GHCR đã scan/ký, canary theo bước 10% -> 50% -> 100%, có AnalysisTemplate. |
| `app-api/service.yaml` | Tạo Service để route traffic tới Pod `api`. |
| `app-api/servicemonitor.yaml` | Cho Prometheus scrape metrics của service `api`. |

### 3.4. Canary analysis và alert

| File | Làm gì |
| --- | --- |
| `app-analysis/analysis-template.yaml` | Định nghĩa AnalysisTemplate `success-rate`, Argo Rollouts dùng để quyết định canary pass/fail dựa trên Prometheus query. |
| `app-alert/prometheus-rules.yaml` | Định nghĩa PrometheusRule cảnh báo khi API error rate cao hoặc pod down. |

### 3.5. External Secrets

| File | Làm gì |
| --- | --- |
| `eso/secret-store.yaml` | SecretStore namespace `demo`, đọc AWS credentials từ Kubernetes Secret `aws-creds`. |
| `eso/cluster-secret-store.yaml` | ClusterSecretStore dùng chung cho tenant khác, ví dụ `payments`, nhưng credential vẫn nằm ở namespace `demo`. |
| `eso/external-secret.yaml` | ExternalSecret sync AWS Secrets Manager key `demo/db/password` thành Kubernetes Secret `db-secret`. |
| `eso/ghcr-pull-secret.yaml` | ExternalSecret sync AWS secret `demo/ghcr/pull-secret` thành Docker config secret `ghcr-pull-secret` ở namespace `demo`. |
| `eso/secret-consumer.yaml` | Deployment test đọc `db-secret` qua volume, chứng minh secret sync và rotate được. |
| `eso/secret-store-irsa.example.yaml` | Mẫu SecretStore dùng IRSA trên EKS thật, không dùng access key tĩnh. Không sync nếu được ignore. |

### 3.6. Sigstore policy

| File | Làm gì |
| --- | --- |
| `policies/cluster-image-policy.yaml` | ClusterImagePolicy yêu cầu image `w10-api` phải có chữ ký Cosign hợp lệ bằng public key đã commit. |

### 3.7. RBAC lab sáng

| File | Làm gì |
| --- | --- |
| `security-rbac-admission/rbac/serviceaccounts.yaml` | Không còn tạo ServiceAccount cho `alice`, `bob`, `carol`; ba persona này là User subject trong RBAC binding. |
| `security-rbac-admission/rbac/roles.yaml` | Tạo Role namespace-scoped cho alice. |
| `security-rbac-admission/rbac/rolebindings.yaml` | Bind Role cho alice trong namespace `demo`. |
| `security-rbac-admission/rbac/clusterrole-platform-viewer.yaml` | Tạo ClusterRole viewer dùng để xem tài nguyên toàn cluster nhưng không sửa/xóa. |
| `security-rbac-admission/rbac/clusterrolebinding-platform-viewer.yaml` | Bind ClusterRole viewer cho bob. |

### 3.8. Workload identity

| File | Làm gì |
| --- | --- |
| `security-rbac-admission/workload-identity/api-serviceaccount.yaml` | Tạo ServiceAccount `api` cho workload, kèm `imagePullSecrets: ghcr-pull-secret`. |
| `security-rbac-admission/workload-identity/api-pod-reader-role.yaml` | Tạo Role cho workload `api` được list/get/watch Pod trong namespace `demo`. |
| `security-rbac-admission/workload-identity/api-pod-reader-binding.yaml` | Bind Role pod-reader cho ServiceAccount `api`. |

### 3.9. Gatekeeper templates

| File | Làm gì |
| --- | --- |
| `gatekeeper/templates/template-disallow-latest-tag.yaml` | Custom Rego: chặn image dùng tag `latest` hoặc không có tag. |
| `gatekeeper/templates/template-required-limits.yaml` | Custom Rego: bắt buộc container có `resources.limits.cpu` và `resources.limits.memory`. |
| `gatekeeper/templates/template-disallow-root-user.yaml` | Custom Rego: chặn `runAsUser: 0`. |
| `gatekeeper/templates/template-disallow-host-network.yaml` | Custom Rego: chặn `hostNetwork: true`. |
| `gatekeeper/templates/template-required-owner-label.yaml` | Custom Rego: bắt buộc workload có label `owner`, áp được cho Pod/Deployment/Rollout. |
| `gatekeeper/templates/template-allowed-image-registries.yaml` | Custom Rego: chỉ cho image từ registry whitelist. |

### 3.10. Gatekeeper constraints

| File | Làm gì |
| --- | --- |
| `gatekeeper/constraints/enforce-core-pod-standards.yaml` | Bật deny cho 4 luật core: no latest, required limits, no root, no hostNetwork. |
| `gatekeeper/constraints/enforce-owner-label.yaml` | Bật deny cho luật owner label trên Pod/Deployment/Rollout. |
| `gatekeeper/constraints/enforce-allowed-image-registries.yaml` | Bật deny cho whitelist registry. |
| `gatekeeper/constraints-warn/*.yaml` | Bản warn/audit của cùng các luật trên, dùng khi muốn kiểm tra vi phạm trước khi enforce. |

### 3.11. Gatekeeper tests

| File | Làm gì |
| --- | --- |
| `tests/test-deny-latest.yaml` | Pod dùng image `:latest`, phải bị reject. |
| `tests/test-deny-missing-limits.yaml` | Pod thiếu limits, phải bị reject. |
| `tests/test-deny-root-user.yaml` | Pod chạy `runAsUser: 0`, phải bị reject. |
| `tests/test-deny-host-network.yaml` | Pod bật `hostNetwork: true`, phải bị reject. |
| `tests/test-deny-missing-owner.yaml` | Pod thiếu label owner, phải bị reject. |
| `tests/test-deny-deployment-missing-owner.yaml` | Deployment thiếu owner, phải bị reject. |
| `tests/test-deny-rollout-missing-owner.yaml` | Rollout thiếu owner, phải bị reject. |
| `tests/test-deny-unapproved-registry.yaml` | Pod dùng registry ngoài whitelist, phải bị reject. |
| `tests/test-allow-secure-pod.yaml` | Pod hợp lệ, phải pass. |
| `tests/test-allow-owner-workloads.yaml` | Deployment/Rollout hợp lệ có owner, phải pass. |

### 3.12. Challenge Payments

| File | Làm gì |
| --- | --- |
| `tenants/payments/namespace.yaml` | Tạo namespace `payments`, label owner/tenant và bật Sigstore include. |
| `tenants/payments/rbac.yaml` | Tạo Role workload-manager và RoleBinding namespace-scoped cho User `payments-dev`. |
| `tenants/payments/quota-limits.yaml` | Tạo ResourceQuota và LimitRange để giới hạn tài nguyên. |
| `tenants/payments/network-policies.yaml` | Default deny ingress, egress chỉ cho cùng namespace và DNS. |
| `tenants/payments/ghcr-pull-secret.yaml` | ExternalSecret tạo `ghcr-pull-secret` trong namespace `payments`. |
| `apps/payments/serviceaccount.yaml` | ServiceAccount `payments-app`, dùng `imagePullSecrets`. |
| `apps/payments/deployment.yaml` | Deployment + Service `payments-api`, workload hợp lệ cho team B. |
| `apps/payments/tests/violating-cross-namespace-curl.yaml` | Pod test cố gọi service namespace `demo`, dùng làm evidence NetworkPolicy. |
| `apps/payments/tests/violating-missing-owner.yaml` | Deployment thiếu owner, dùng làm evidence Gatekeeper reject. |
| `evidence/payments/quota-violation.yaml` | Pod vượt ResourceQuota, phải bị reject. |
| `evidence/payments/limitrange-default-demo.yaml` | Pod không khai báo resources để chứng minh LimitRange cấp default. |

## 4. Giải thích pattern từng line

### 4.1. Kubernetes manifest cơ bản

Ví dụ:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo
  labels:
    owner: platform-team
spec:
  ...
```

Giải thích:

- `apiVersion`: version API Kubernetes dùng để hiểu object này thuộc nhóm nào.
- `kind`: loại resource, ví dụ `Namespace`, `Service`, `Deployment`, `Role`.
- `metadata`: thông tin định danh của object.
- `metadata.name`: tên resource trong cluster.
- `metadata.namespace`: namespace resource thuộc về. Resource cluster-scoped như `Namespace`, `ClusterRole`, `ClusterImagePolicy` không có dòng này.
- `metadata.labels`: key/value để select, group, policy match.
- `metadata.annotations`: metadata phụ, ArgoCD dùng `sync-wave`; Prometheus/Gatekeeper cũng có thể dùng.
- `spec`: desired state, tức trạng thái mong muốn.

### 4.2. ArgoCD Application

Ví dụ từ `argocd/apps/payments-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: payments-app
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "6"
spec:
  project: default
  source:
    repoURL: https://github.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2.git
    path: cloud/w10/temp/apps/payments
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: payments
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ServerSideApply=true
      - SkipDryRunOnMissingResource=true
```

Giải thích từng dòng/pattern:

- `apiVersion: argoproj.io/v1alpha1`: object này thuộc CRD của ArgoCD.
- `kind: Application`: khai báo một app GitOps.
- `metadata.name`: tên app hiển thị trong ArgoCD UI.
- `metadata.namespace: argocd`: Application object nằm trong namespace `argocd`.
- `sync-wave`: điều khiển thứ tự sync, số nhỏ chạy trước số lớn.
- `spec.project`: project ArgoCD, lab dùng `default`.
- `spec.source.repoURL`: Git repo ArgoCD sẽ kéo manifest.
- `spec.source.path`: folder trong repo chứa manifest.
- `spec.source.targetRevision`: branch/tag/commit, ở đây là `main`.
- `spec.destination.server`: cluster đích, `kubernetes.default.svc` là in-cluster.
- `spec.destination.namespace`: namespace mặc định khi apply resource.
- `syncPolicy.automated`: bật auto-sync.
- `prune: true`: xóa resource ngoài cluster nếu file bị xóa khỏi Git.
- `selfHeal: true`: nếu ai sửa tay ngoài cluster, ArgoCD tự đưa về theo Git.
- `ServerSideApply=true`: dùng server-side apply, hợp với CRD lớn.
- `SkipDryRunOnMissingResource=true`: tránh lỗi dry-run khi CRD chưa kịp xuất hiện.

### 4.3. Helm chart Application

Một số app như `gatekeeper`, `eso`, `k8s-prometheus`, `policy-controller` không trỏ vào path local mà trỏ Helm repo.

Pattern:

```yaml
source:
  repoURL: https://...
  chart: chart-name
  targetRevision: x.y.z
  helm:
    values: |
      key: value
```

Giải thích:

- `repoURL`: Helm repository.
- `chart`: tên chart cần install.
- `targetRevision`: version chart.
- `helm.values`: override cấu hình chart.

### 4.4. RBAC

Pattern Role:

```yaml
kind: Role
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "create"]
```

Giải thích:

- `Role`: quyền trong một namespace.
- `ClusterRole`: quyền cấp toàn cluster hoặc dùng lại ở nhiều namespace.
- `apiGroups`: nhóm API, ví dụ `""` là core API như Pod/Service, `"apps"` là Deployment.
- `resources`: tài nguyên được thao tác.
- `verbs`: hành động được phép.

Pattern RoleBinding:

```yaml
subjects:
  - kind: User
    name: alice
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: workload-manager
  apiGroup: rbac.authorization.k8s.io
```

Giải thích:

- `subjects`: ai nhận quyền.
- `kind: ServiceAccount`: người nhận quyền là service account.
- `roleRef`: trỏ tới Role/ClusterRole được bind.
- `RoleBinding`: bind quyền trong namespace.
- `ClusterRoleBinding`: bind quyền toàn cluster.

### 4.5. Workload Deployment/Rollout

Pattern:

```yaml
spec:
  replicas: 2
  selector:
    matchLabels:
      app: payments-api
  template:
    metadata:
      labels:
        app: payments-api
        owner: payments-team
    spec:
      serviceAccountName: payments-app
      imagePullSecrets:
        - name: ghcr-pull-secret
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
      containers:
        - name: api
          image: ghcr.io/.../w10-api:0.0.4
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 200m
              memory: 128Mi
```

Giải thích:

- `replicas`: số Pod mong muốn.
- `selector.matchLabels`: Deployment/Rollout quản lý Pod có label này.
- `template.metadata.labels`: label gắn vào Pod được tạo.
- `serviceAccountName`: Pod chạy dưới identity nào.
- `imagePullSecrets`: secret dùng để pull image private.
- `securityContext.runAsNonRoot`: yêu cầu container không chạy root.
- `runAsUser: 10001`: UID non-root.
- `containers[].image`: image chạy trong Pod. Không dùng `latest`.
- `resources.requests`: tài nguyên scheduler dùng để đặt Pod.
- `resources.limits`: trần tài nguyên; Gatekeeper bắt buộc có.

### 4.6. Service

Pattern:

```yaml
kind: Service
spec:
  selector:
    app: payments-api
  ports:
    - port: 80
      targetPort: 8080
```

Giải thích:

- `selector`: chọn Pod backend.
- `port`: port service expose trong cluster.
- `targetPort`: port container thật.

### 4.7. ExternalSecret

Pattern:

```yaml
kind: ExternalSecret
spec:
  refreshInterval: 30s
  secretStoreRef:
    name: aws-store
    kind: SecretStore
  target:
    name: db-secret
  data:
    - secretKey: password
      remoteRef:
        key: demo/db/password
```

Giải thích:

- `refreshInterval`: ESO check AWS lại sau bao lâu.
- `secretStoreRef`: dùng SecretStore/ClusterSecretStore nào để connect AWS.
- `target.name`: Kubernetes Secret được tạo.
- `data.secretKey`: key trong Kubernetes Secret.
- `remoteRef.key`: key trong AWS Secrets Manager.

### 4.8. SecretStore và ClusterSecretStore

Pattern:

```yaml
provider:
  aws:
    service: SecretsManager
    region: ap-southeast-1
    auth:
      secretRef:
        accessKeyIDSecretRef:
          name: aws-creds
          key: access-key
```

Giải thích:

- `service: SecretsManager`: ESO đọc AWS Secrets Manager.
- `region`: region AWS.
- `auth.secretRef`: credential lấy từ Kubernetes Secret.
- `SecretStore`: chỉ dùng trong một namespace.
- `ClusterSecretStore`: dùng được từ nhiều namespace.

### 4.9. Gatekeeper ConstraintTemplate

Pattern:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredownerlabel
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredOwnerLabel
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredownerlabel
        violation[{"msg": msg}] {
          ...
        }
```

Giải thích:

- `ConstraintTemplate`: định nghĩa loại policy mới.
- `metadata.name`: tên template, thường lowercase.
- `spec.crd.spec.names.kind`: tạo kind mới dưới group `constraints.gatekeeper.sh`.
- `targets`: policy chạy vào admission webhook của Gatekeeper.
- `rego`: code policy.
- `package`: namespace trong Rego.
- `violation`: nếu rule match thì Gatekeeper reject/warn.
- `msg`: message trả về cho user.

### 4.10. Gatekeeper Constraint

Pattern:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredOwnerLabel
metadata:
  name: require-owner-label
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
    namespaces: ["demo", "payments"]
```

Giải thích:

- `kind`: kind do ConstraintTemplate tạo ra.
- `enforcementAction: deny`: vi phạm thì reject.
- `enforcementAction: warn`: vi phạm chỉ warning/audit.
- `match.kinds`: policy áp vào loại object nào.
- `match.namespaces`: chỉ áp vào namespace nào.

### 4.11. NetworkPolicy

Pattern:

```yaml
kind: NetworkPolicy
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  egress:
    - to:
        - podSelector: {}
```

Giải thích:

- `podSelector: {}`: áp vào tất cả Pod trong namespace.
- `policyTypes`: loại traffic bị kiểm soát.
- Nếu có `policyTypes: Ingress` mà không có `ingress`, mặc định chặn inbound.
- Nếu có `policyTypes: Egress`, chỉ allow rule được khai báo trong `egress`.
- NetworkPolicy chỉ enforce nếu CNI hỗ trợ, ví dụ Calico.

### 4.12. ResourceQuota và LimitRange

ResourceQuota:

```yaml
hard:
  requests.cpu: "1"
  requests.memory: 1Gi
  limits.cpu: "2"
  limits.memory: 2Gi
  pods: "10"
```

Giải thích:

- Tổng requests/limits/pods trong namespace không được vượt các giá trị này.

LimitRange:

```yaml
defaultRequest:
  cpu: 50m
  memory: 64Mi
default:
  cpu: 200m
  memory: 128Mi
max:
  cpu: "1"
  memory: 1Gi
```

Giải thích:

- `defaultRequest`: nếu Pod không khai request, Kubernetes tự thêm.
- `default`: nếu Pod không khai limit, Kubernetes tự thêm.
- `max`: giới hạn tối đa mỗi container.

### 4.13. ClusterImagePolicy

Pattern:

```yaml
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: require-signed-w10-api
spec:
  mode: enforce
  images:
    - glob: ghcr.io/.../w10-api*
  authorities:
    - name: authority-0
      key:
        data: |
          -----BEGIN PUBLIC KEY-----
```

Giải thích:

- `ClusterImagePolicy`: policy admission của Sigstore Policy Controller.
- `mode: enforce`: image không hợp lệ thì reject.
- `images.glob`: image nào bị kiểm tra chữ ký.
- `authorities`: nguồn tin cậy.
- `key.data`: public key Cosign dùng để verify signature.

## 5. Giải thích chi tiết luồng Challenge Payments

### 5.1. `argocd/apps/payments.yaml`

```text
Application payments
-> source.path = cloud/w10/temp/tenants/payments
-> destination.namespace = payments
-> sync wave 5
```

Ý nghĩa:

- Tạo hạ tầng tenant trước.
- Folder này gồm namespace, RBAC, quota, network policy, pull secret.

### 5.2. `tenants/payments/namespace.yaml`

Ý nghĩa từng phần:

- `kind: Namespace`: tạo namespace riêng cho team B.
- `metadata.name: payments`: tên namespace.
- `labels.owner: payments-team`: phục vụ governance/evidence.
- `labels.tenant: payments`: phân biệt tenant.
- `policy.sigstore.dev/include: "true"`: Sigstore Policy Controller sẽ verify image trong namespace này.

### 5.3. `tenants/payments/rbac.yaml`

Luồng quyền:

```text
User payments-dev
  -> Role payments-workload-manager
  -> RoleBinding payments-dev-workload-manager
```

Ý nghĩa:

- User `payments-dev` được phép quản lý workload trong namespace `payments`.
- Không có quyền sang `demo`.
- Không có quyền `secrets`.
- Không có quyền `rolebindings`, tránh tự leo quyền.

### 5.4. `tenants/payments/quota-limits.yaml`

Luồng:

```text
ResourceQuota payments-budget
  -> giới hạn tổng tài nguyên namespace

LimitRange payments-defaults
  -> default request/limit cho container nếu user quên khai báo
```

Ý nghĩa:

- Chứng minh quota chặn vượt.
- Chứng minh LimitRange tự cấp default.

### 5.5. `tenants/payments/network-policies.yaml`

Luồng:

```text
payments-default-deny-ingress
  -> chặn inbound vào Pod payments nếu không có allow rule

payments-egress-same-namespace-and-dns
  -> chỉ cho egress tới Pod cùng namespace và DNS kube-system
```

Ý nghĩa:

- Payments không gọi chéo sang `demo`.
- Pod vẫn resolve DNS được.

### 5.6. `tenants/payments/ghcr-pull-secret.yaml`

Luồng:

```text
AWS Secrets Manager: demo/ghcr/pull-secret
  -> ClusterSecretStore aws-cluster-store
  -> ExternalSecret payments-ghcr-pull-secret
  -> Kubernetes Secret payments/ghcr-pull-secret
  -> ServiceAccount payments-app imagePullSecrets
```

Ý nghĩa:

- Không commit GHCR token.
- Mỗi namespace có pull secret riêng.

### 5.7. `argocd/apps/payments-app.yaml`

```text
Application payments-app
-> source.path = cloud/w10/temp/apps/payments
-> destination.namespace = payments
-> sync wave 6
```

Ý nghĩa:

- Chạy sau tenant platform.
- Khi app sync, namespace/quota/netpol/pull secret đã sẵn sàng.

### 5.8. `apps/payments/serviceaccount.yaml`

Ý nghĩa:

- `ServiceAccount payments-app`: identity runtime của workload.
- `imagePullSecrets: ghcr-pull-secret`: Pod dùng secret này để pull private image GHCR.

### 5.9. `apps/payments/deployment.yaml`

Ý nghĩa:

- `Deployment payments-api`: workload hợp lệ của team B.
- Có `owner` label để pass Gatekeeper.
- Có image pinned `0.0.4`, không dùng latest.
- Có `resources.requests/limits`.
- Có `runAsNonRoot` và `runAsUser: 10001`.
- Có Service để expose trong cluster.

### 5.10. Test files của Payments

```text
apps/payments/tests/violating-missing-owner.yaml
  -> Deployment thiếu owner
  -> Gatekeeper phải reject

apps/payments/tests/violating-cross-namespace-curl.yaml
  -> Pod thử gọi service ở demo
  -> NetworkPolicy phải chặn

evidence/payments/quota-violation.yaml
  -> Pod request/limit quá quota
  -> ResourceQuota phải reject

evidence/payments/limitrange-default-demo.yaml
  -> Pod không khai resources
  -> LimitRange tự default
```

## 6. Luồng chứng minh đạt bài

```text
1. ArgoCD root sync
2. ArgoCD tạo payments và payments-app
3. payments namespace có RBAC/quota/netpol/pull secret
4. payments-app deploy payments-api
5. Gatekeeper kiểm workload payments
6. Sigstore kiểm image w10-api
7. ESO tạo ghcr-pull-secret
8. Pod payments-api pull image và Running
9. Test vi phạm:
   - can-i sang namespace khác -> no
   - vượt quota -> reject
   - gọi chéo demo -> failed/timeout
   - thiếu owner -> reject
```

## 7. Những dòng dễ nhầm

### `--as alice` khác gì `--as alice`?

Trong bản hiện tại, `alice` là Kubernetes User được giả lập bằng `--as`, không phải ServiceAccount. Vì vậy dùng:

```bash
--as alice
```

Nếu dùng:

```bash
--as alice
```

thì Kubernetes hiểu là ServiceAccount `alice` trong namespace `demo`. Bản hiện tại không bind quyền cho ServiceAccount này.

### Vì sao `payments-dev` dùng Role, không dùng ClusterRoleBinding?

Vì bài cần chứng minh cô lập tenant. `RoleBinding` trong namespace `payments` chỉ cấp quyền ở `payments`. `ClusterRoleBinding` dễ làm user có quyền toàn cluster.

### Vì sao `constraints-warn` vẫn tồn tại?

Để audit trước khi bật deny. Bản đang sync cho bài challenge là:

```text
security-rbac-admission/gatekeeper/constraints
```

Tức là manifest vi phạm sẽ bị reject thật.

### Vì sao có cả `SecretStore` và `ClusterSecretStore`?

- `SecretStore aws-store`: dùng trong namespace `demo`.
- `ClusterSecretStore aws-cluster-store`: dùng được từ `payments`, vì ExternalSecret ở namespace khác không thể tham chiếu SecretStore namespace `demo`.

### Vì sao app payments dùng lại image `w10-api`?

Bài challenge cần chứng minh guardrail/supply-chain áp cho tenant mới. Dùng lại image đã scan và ký giúp tập trung vào platform control: RBAC, quota, netpol, Gatekeeper, Sigstore, pull secret.

## 8. Kịch bản giải thích khi thuyết trình

Phần này viết theo cách có thể nói trực tiếp khi demo.

### 8.1. Mở đầu tổng quan

Có thể nói:

```text
Tuần 10 của em là một mini platform end-to-end. Em dùng GitOps để deploy app, dùng RBAC để giới hạn quyền, dùng Gatekeeper để chặn manifest không an toàn, dùng ESO để không commit secret vào Git, dùng Trivy/Cosign/Sigstore để bảo vệ supply chain, và cuối cùng onboard thêm tenant payments để chứng minh platform scale được sang team mới.
```

Luồng chính:

```text
GitHub repo
  -> ArgoCD root app
  -> child apps trong argocd/apps
  -> controllers/CRDs
  -> app demo + security guardrails
  -> tenant payments
```

## 9. Lab sáng - RBAC và Gatekeeper chi tiết

Ý tưởng mở đầu:

```text
Lớp phòng thủ đầu tiên là kiểm soát ai được quyền làm gì bằng RBAC, và kiểm tra manifest đầu vào bằng Gatekeeper trước khi object được tạo trong cluster.
```

### 9.1. `rbac/serviceaccounts.yaml`

File này tạo identity giả lập cho lab.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: alice
  namespace: demo
```

Giải thích từng dòng:

- `apiVersion: v1`: ServiceAccount là resource core của Kubernetes.
- User `alice` không cần manifest tạo identity; Kubernetes nhận tên user qua authentication/impersonation và RBAC bind vào tên đó.
- `metadata.name: alice`: tên identity là `alice`.
- `metadata.namespace: demo`: alice chỉ tồn tại trong namespace `demo`.

Vì vậy khi test phải dùng:

```bash
--as alice
```

không dùng:

```bash
--as alice
```

### 9.2. `rbac/roles.yaml`

File này tạo Role cho alice.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: demo-deployer
  namespace: demo
rules:
  - apiGroups: ["", "apps", "argoproj.io"]
    resources:
      - pods
      - pods/log
      - services
      - configmaps
      - deployments
      - replicasets
      - rollouts
    verbs: ["get", "list", "watch", "create", "update", "patch"]
```

Giải thích:

- `apiVersion: rbac.authorization.k8s.io/v1`: dùng API RBAC.
- `kind: Role`: quyền chỉ có hiệu lực trong một namespace.
- `metadata.name: demo-deployer`: tên Role.
- `metadata.namespace: demo`: Role này chỉ nằm trong `demo`.
- `rules`: danh sách quyền.
- `apiGroups: ["", "apps", "argoproj.io"]`: cho phép thao tác resource ở core API, apps API và Argo Rollouts API.
- `resources`: các loại tài nguyên alice được thao tác.
- `pods/log`: quyền đọc log pod, đây là subresource khác với `pods`.
- `rollouts`: cho phép thao tác Argo Rollout.
- `verbs`: hành động được phép.

Điểm quan trọng:

```text
Không có secrets.
Không có nodes.
Không có rolebindings.
Không có delete.
```

Nên alice deploy được workload trong `demo` nhưng không đọc secret, không xóa node, không tự cấp thêm quyền.

### 9.3. `rbac/rolebindings.yaml`

File này gắn Role cho alice.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: alice-demo-deployer
  namespace: demo
subjects:
  - kind: User
    name: alice
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: demo-deployer
```

Giải thích:

- `kind: RoleBinding`: gắn quyền trong namespace.
- `metadata.namespace: demo`: binding chỉ có hiệu lực trong `demo`.
- `subjects`: người nhận quyền.
- `kind: User`: subject là Kubernetes User được giả lập bằng `kubectl auth can-i --as`.
- `name: alice`: bind cho alice.
- `roleRef.kind: Role`: quyền được lấy từ Role, không phải ClusterRole.
- `roleRef.name: demo-deployer`: trỏ tới Role đã tạo ở trên.

Kết quả:

```text
alice create deploy -n demo        -> yes
alice create deploy -n kube-system -> no
```

Vì RoleBinding chỉ nằm trong `demo`.

### 9.4. `rbac/clusterrole-platform-viewer.yaml`

File này tạo quyền xem pod toàn cluster cho bob.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: platform-pod-viewer
rules:
  - apiGroups: [""]
    resources:
      - pods
      - pods/log
      - namespaces
    verbs: ["get", "list", "watch"]
```

Giải thích:

- `kind: ClusterRole`: quyền không bị giới hạn bởi một namespace.
- `resources: pods, pods/log, namespaces`: bob xem được pod/log/namespace.
- `verbs: get/list/watch`: chỉ đọc, không sửa, không xóa.

### 9.5. `rbac/clusterrolebinding-platform-viewer.yaml`

```yaml
kind: ClusterRoleBinding
metadata:
  name: bob-platform-pod-viewer
subjects:
  - kind: User
    name: bob
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: platform-pod-viewer
```

Giải thích:

- `ClusterRoleBinding`: bind quyền ở phạm vi cluster.
- `bob` vẫn là ServiceAccount trong namespace `demo`.
- Nhưng vì bind bằng ClusterRoleBinding nên bob có thể `get pods -A`.

Kết quả:

```text
bob get pods -A -> yes
```

### 9.6. Vì sao carol delete nodes là no?

Carol có ServiceAccount nhưng không có RoleBinding/ClusterRoleBinding cấp quyền delete node.

Node là resource cluster-scoped, muốn xóa node cần quyền rất lớn:

```text
apiGroup: ""
resource: nodes
verb: delete
```

Lab không cấp quyền này, nên:

```text
carol delete nodes -> no
```

## 10. Gatekeeper chi tiết

Ý tưởng:

```text
RBAC kiểm tra ai được gửi request. Gatekeeper kiểm tra nội dung request có an toàn không. Người có quyền create Pod vẫn không được tạo Pod nếu manifest vi phạm policy.
```

### 10.1. ConstraintTemplate là gì?

Ví dụ `template-required-owner-label.yaml`:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredownerlabel
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredOwnerLabel
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredownerlabel
```

Giải thích:

- `apiVersion: templates.gatekeeper.sh/v1`: API của Gatekeeper template.
- `kind: ConstraintTemplate`: định nghĩa một loại policy mới.
- `metadata.name`: tên template, dùng lowercase.
- `spec.crd.spec.names.kind`: sau khi apply, Kubernetes có thêm kind `K8sRequiredOwnerLabel`.
- `target: admission.k8s.gatekeeper.sh`: policy chạy ở admission webhook.
- `rego`: code Rego thực hiện logic kiểm tra.
- `package`: namespace logic trong Rego.

Nói ngắn:

```text
Template tạo ra loại luật mới.
Constraint bật loại luật đó lên tài nguyên thật.
```

### 10.2. Constraint owner label

File `constraints/enforce-owner-label.yaml`:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredOwnerLabel
metadata:
  name: require-owner-label
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
      - apiGroups: ["argoproj.io"]
        kinds: ["Rollout"]
    namespaces: ["demo", "payments"]
```

Giải thích:

- `kind: K8sRequiredOwnerLabel`: kind này do ConstraintTemplate tạo ra.
- `metadata.name: require-owner-label`: tên constraint.
- `enforcementAction: deny`: nếu vi phạm thì reject.
- `match.kinds`: áp vào Pod, Deployment, Rollout.
- `apiGroups: [""]`: core API, nơi Pod nằm.
- `apiGroups: ["apps"]`: nơi Deployment nằm.
- `apiGroups: ["argoproj.io"]`: nơi Rollout nằm.
- `namespaces: ["demo", "payments"]`: policy áp cho cả lab chính và tenant challenge.

Điểm ăn điểm:

```text
Constraint cũ không chỉ áp cho demo nữa, mà đã mở rộng sang payments.
```

### 10.3. Core pod standards

File `constraints/enforce-core-pod-standards.yaml` bật 4 luật:

```text
K8sDisallowLatestTag     -> chặn image latest hoặc thiếu tag
K8sRequiredLimits        -> bắt buộc resources.limits.cpu/memory
K8sDisallowRootUser      -> chặn runAsUser: 0
K8sDisallowHostNetwork   -> chặn hostNetwork: true
```

Các luật đều match:

```yaml
match:
  kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
  namespaces: ["demo", "payments"]
```

Nghĩa là:

- Khi Deployment/Rollout tạo Pod, Pod cuối cùng vẫn bị kiểm tra.
- Namespace `payments` trong challenge cũng bị kiểm tra.

### 10.4. Allowed registry

File `constraints/enforce-allowed-image-registries.yaml`:

```yaml
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces: ["demo", "payments"]
  parameters:
    registries:
      - ghcr.io/
      - docker.io/library/
```

Giải thích:

- Chỉ Pod trong `demo` và `payments` bị kiểm tra.
- Chỉ image bắt đầu bằng `ghcr.io/` hoặc `docker.io/library/` được phép.
- `parameters.registries` là dữ liệu truyền vào Rego.

## 11. Lab chiều - ESO, Secret, GHCR pull secret

Ý tưởng mở đầu:

```text
Lớp phòng thủ thứ hai là không để secret thật trong Git. Secret thật nằm ở AWS Secrets Manager, Kubernetes chỉ nhận bản sync qua External Secrets Operator.
```

### 11.1. `eso/secret-store.yaml`

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-store
  namespace: demo
spec:
  provider:
    aws:
      service: SecretsManager
      region: ap-southeast-1
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: aws-creds
            key: access-key
          secretAccessKeySecretRef:
            name: aws-creds
            key: secret-key
```

Giải thích:

- `apiVersion: external-secrets.io/v1beta1`: API của ESO.
- `kind: SecretStore`: cách kết nối secret provider trong một namespace.
- `metadata.name: aws-store`: tên store để ExternalSecret gọi tới.
- `metadata.namespace: demo`: store này nằm trong namespace `demo`.
- `provider.aws.service: SecretsManager`: nguồn secret là AWS Secrets Manager.
- `region: ap-southeast-1`: region AWS chứa secret.
- `auth.secretRef`: ESO lấy AWS credential từ Kubernetes Secret.
- `accessKeyIDSecretRef.name: aws-creds`: secret chứa access key.
- `key: access-key`: key cụ thể trong Kubernetes Secret.
- `secretAccessKeySecretRef`: tương tự cho secret key.

Điểm quan trọng:

```text
aws-creds không commit vào Git. Nó được tạo bằng kubectl create secret từ terminal.
```

### 11.2. `eso/external-secret.yaml`

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-creds
  namespace: demo
spec:
  refreshInterval: 30s
  secretStoreRef:
    name: aws-store
    kind: SecretStore
  target:
    name: db-secret
    creationPolicy: Owner
  data:
    - secretKey: password
      remoteRef:
        key: demo/db/password
```

Giải thích:

- `kind: ExternalSecret`: yêu cầu ESO sync secret từ external provider.
- `metadata.name: db-creds`: tên ExternalSecret.
- `refreshInterval: 30s`: cứ 30 giây ESO kiểm tra AWS một lần.
- `secretStoreRef.name: aws-store`: dùng SecretStore đã tạo ở trên.
- `target.name: db-secret`: Kubernetes Secret cuối cùng được tạo.
- `creationPolicy: Owner`: ExternalSecret sở hữu Secret này, xóa ExternalSecret thì Secret cũng theo lifecycle của nó.
- `data.secretKey: password`: key trong Kubernetes Secret là `password`.
- `remoteRef.key: demo/db/password`: secret thật nằm ở AWS Secrets Manager với key này.

Luồng:

```text
AWS Secrets Manager demo/db/password
  -> ESO db-creds
  -> Kubernetes Secret demo/db-secret
  -> secret-consumer đọc /etc/db/password
```

### 11.3. `eso/ghcr-pull-secret.yaml`

File này giải quyết lỗi private GHCR image pull.

```yaml
target:
  name: ghcr-pull-secret
  creationPolicy: Owner
  template:
    type: kubernetes.io/dockerconfigjson
```

Giải thích:

- `target.name: ghcr-pull-secret`: tạo Kubernetes Secret tên này.
- `template.type: kubernetes.io/dockerconfigjson`: secret đúng format Docker registry auth.

Đoạn template:

```yaml
.dockerconfigjson: |
  {
    "auths": {
      "ghcr.io": {
        "username": "{{ .username }}",
        "password": "{{ .password }}",
        "auth": "{{ printf "%s:%s" .username .password | b64enc }}"
      }
    }
  }
```

Giải thích:

- `.dockerconfigjson`: key bắt buộc của secret Docker config.
- `ghcr.io`: registry cần login.
- `{{ .username }}` và `{{ .password }}`: dữ liệu lấy từ AWS secret.
- `auth`: base64 của `username:password`, Docker cần field này để pull image.

Đoạn data:

```yaml
data:
  - secretKey: username
    remoteRef:
      key: demo/ghcr/pull-secret
      property: username
  - secretKey: password
    remoteRef:
      key: demo/ghcr/pull-secret
      property: password
```

Nghĩa là AWS secret `demo/ghcr/pull-secret` là JSON có:

```json
{"username":"...","password":"..."}
```

ESO tách `username` và `password` ra để render Docker config.

## 12. Lab chiều - Supply chain chi tiết

Ý tưởng mở đầu:

```text
Secret an toàn chưa đủ. Image cũng phải an toàn: build qua pipeline, scan bằng Trivy, ký bằng Cosign, rồi cluster chỉ cho chạy image đã ký.
```

### 12.1. GitHub Actions build, scan, sign

Workflow `.github/workflows/w10-temp-build-push.yml` làm các bước chính:

```text
checkout source
-> build Docker image
-> run Trivy scan
-> push image to GHCR
-> cosign sign image
-> update rollout.yaml image tag
-> commit version bump
```

Biến quan trọng:

```text
COSIGN_PRIVATE_KEY
COSIGN_PASSWORD
```

được lưu trong GitHub Secrets, không commit vào repo.

### 12.2. `policies/cluster-image-policy.yaml`

```yaml
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: require-signed-w10-api
spec:
  mode: enforce
  images:
    - glob: ghcr.io/x-brain-cdo-09/lehoangtrungkien-aws-accelerator-p2/w10-api*
  authorities:
    - name: authority-0
      key:
        data: |
          -----BEGIN PUBLIC KEY-----
```

Giải thích:

- `apiVersion: policy.sigstore.dev/v1beta1`: API của Sigstore Policy Controller.
- `kind: ClusterImagePolicy`: policy cấp cluster để verify image.
- `metadata.name`: tên policy.
- `mode: enforce`: image không hợp lệ thì reject, không chỉ cảnh báo.
- `images.glob`: chỉ kiểm tra image match pattern này.
- `authorities`: danh sách nguồn tin cậy.
- `name: authority-0`: tên authority, thêm để khớp default live manifest của controller.
- `key.data`: public key Cosign dùng để verify signature.

Luồng:

```text
Pod muốn chạy image w10-api
  -> admission gọi Policy Controller
  -> Policy Controller dùng public key verify chữ ký
  -> pass thì Pod được tạo
  -> fail thì Pod bị reject
```

## 13. Challenge Payments chi tiết

Ý tưởng mở đầu:

```text
Challenge chứng minh platform không chỉ chạy cho namespace demo. Em onboard thêm tenant payments với quyền riêng, quota riêng, network policy riêng, nhưng vẫn dùng lại guardrail cũ của platform.
```

### 13.1. `tenants/payments/namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: payments
  labels:
    owner: payments-team
    tenant: payments
    policy.sigstore.dev/include: "true"
```

Giải thích:

- `kind: Namespace`: tạo phòng riêng.
- `name: payments`: tên namespace.
- `owner: payments-team`: team sở hữu.
- `tenant: payments`: đánh dấu tenant.
- `policy.sigstore.dev/include: "true"`: bật Sigstore verify image trong namespace này.

### 13.2. `tenants/payments/rbac.yaml`

File này gồm 3 object.

Object 1:

```yaml
kind: RoleBinding
metadata:
  name: payments-dev-workload-manager
  namespace: payments
```

Ý nghĩa: tạo identity cho developer/team Payments.

Object 2:

```yaml
kind: Role
metadata:
  name: payments-workload-manager
  namespace: payments
rules:
  - apiGroups: [""]
    resources:
      - pods
      - pods/log
      - services
      - configmaps
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

Giải thích:

- Role nằm trong namespace `payments`.
- Cho thao tác workload cơ bản.
- Có `pods/log` để xem log.
- Không có `secrets`.
- Không có `roles` hoặc `rolebindings`.

Object 3:

```yaml
kind: RoleBinding
metadata:
  name: payments-dev-workload-manager
  namespace: payments
subjects:
  - kind: User
    name: payments-dev
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: payments-workload-manager
```

Ý nghĩa:

```text
payments-dev nhận Role payments-workload-manager, nhưng chỉ trong namespace payments.
```

Kết quả:

```text
create deploy -n payments       -> yes
create deploy -n demo           -> no
get secrets -n payments         -> no
update rolebindings -n payments -> no
```

### 13.3. `tenants/payments/quota-limits.yaml`

ResourceQuota:

```yaml
kind: ResourceQuota
metadata:
  name: payments-budget
  namespace: payments
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "10"
    services: "5"
```

Giải thích:

- `requests.cpu`: tổng CPU request không quá 1 core.
- `requests.memory`: tổng memory request không quá 1Gi.
- `limits.cpu`: tổng CPU limit không quá 2 core.
- `limits.memory`: tổng memory limit không quá 2Gi.
- `pods`: tối đa 10 pod.
- `services`: tối đa 5 service.

LimitRange:

```yaml
kind: LimitRange
metadata:
  name: payments-defaults
  namespace: payments
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 50m
        memory: 64Mi
      default:
        cpu: 200m
        memory: 128Mi
      max:
        cpu: "1"
        memory: 1Gi
```

Giải thích:

- `type: Container`: rule áp cho từng container.
- `defaultRequest`: nếu không khai request thì tự thêm.
- `default`: nếu không khai limit thì tự thêm.
- `max`: container không được vượt quá mức này.

### 13.4. `tenants/payments/network-policies.yaml`

Object 1:

```yaml
kind: NetworkPolicy
metadata:
  name: payments-default-deny-ingress
  namespace: payments
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Giải thích:

- `podSelector: {}`: áp vào tất cả Pod trong namespace payments.
- `policyTypes: Ingress`: kiểm soát traffic đi vào.
- Không khai `ingress:` nghĩa là không allow inbound nào, tức default deny ingress.

Object 2:

```yaml
kind: NetworkPolicy
metadata:
  name: payments-egress-same-namespace-and-dns
  namespace: payments
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - podSelector: {}
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

Giải thích:

- `policyTypes: Egress`: kiểm soát traffic đi ra.
- Rule đầu `podSelector: {}`: cho gọi Pod cùng namespace payments.
- Rule thứ hai `namespaceSelector kube-system` + `podSelector kube-dns`: cho gọi DNS.
- `UDP/TCP 53`: port DNS.
- Không có rule nào tới namespace `demo`, nên gọi chéo sang demo bị timeout/failed.

### 13.5. `tenants/payments/ghcr-pull-secret.yaml`

```yaml
secretStoreRef:
  name: aws-cluster-store
  kind: ClusterSecretStore
target:
  name: ghcr-pull-secret
```

Giải thích:

- Payments không dùng `SecretStore aws-store` vì store đó namespace-scoped ở `demo`.
- Payments dùng `ClusterSecretStore aws-cluster-store`, có thể dùng từ namespace khác.
- Kết quả vẫn tạo secret local trong namespace `payments`: `ghcr-pull-secret`.

### 13.6. `apps/payments/serviceaccount.yaml`

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: payments-app
  namespace: payments
imagePullSecrets:
  - name: ghcr-pull-secret
```

Giải thích:

- `payments-app`: runtime identity của Pod app.
- `imagePullSecrets`: mọi Pod dùng SA này có thể pull private image từ GHCR.

### 13.7. `apps/payments/deployment.yaml`

Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments-api
  namespace: payments
  labels:
    app: payments-api
    owner: payments-team
    tenant: payments
spec:
  replicas: 2
```

Giải thích:

- `Deployment`: workload thường, không canary như Rollout.
- `owner` label giúp pass Gatekeeper.
- `replicas: 2`: chạy 2 Pod.

Pod template:

```yaml
template:
  metadata:
    labels:
      app: payments-api
      owner: payments-team
      tenant: payments
  spec:
    serviceAccountName: payments-app
    imagePullSecrets:
      - name: ghcr-pull-secret
    securityContext:
      runAsNonRoot: true
      runAsUser: 10001
```

Giải thích:

- Pod template cũng có `owner`, vì Gatekeeper kiểm cả Pod được tạo ra.
- `serviceAccountName`: chạy bằng identity `payments-app`.
- `imagePullSecrets`: pull GHCR private image.
- `runAsNonRoot` và `runAsUser: 10001`: pass rule không chạy root.

Container:

```yaml
containers:
  - name: api
    image: ghcr.io/x-brain-cdo-09/lehoangtrungkien-aws-accelerator-p2/w10-api:0.0.4
    imagePullPolicy: IfNotPresent
    ports:
      - containerPort: 8080
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 128Mi
```

Giải thích:

- Image dùng tag pinned `0.0.4`, không dùng `latest`.
- Image này đã được workflow scan và ký.
- `containerPort: 8080`: app listen port 8080.
- `resources.requests/limits`: pass Gatekeeper required limits và nằm trong quota.

Service:

```yaml
kind: Service
metadata:
  name: payments-api
spec:
  selector:
    app: payments-api
  ports:
    - port: 80
      targetPort: 8080
```

Giải thích:

- Service chọn Pod có label `app: payments-api`.
- Client gọi service port 80.
- Kubernetes forward vào container port 8080.

### 13.8. Test challenge

`apps/payments/tests/violating-missing-owner.yaml`:

```text
Deployment thiếu label owner
-> Gatekeeper constraint require-owner-label reject
```

`apps/payments/tests/violating-cross-namespace-curl.yaml`:

```text
Pod thử wget service demo
-> NetworkPolicy không allow egress sang demo
-> timeout/failed
```

`evidence/payments/quota-violation.yaml`:

```text
Pod request/limit memory 3Gi
-> vượt ResourceQuota payments-budget
-> reject
```

`evidence/payments/limitrange-default-demo.yaml`:

```text
Pod không khai resources
-> LimitRange payments-defaults tự thêm defaultRequest/default
```

## 14. Câu trả lời ngắn khi mentor hỏi "Vì sao thiết kế vậy?"

### Vì sao cần cả RBAC và Gatekeeper?

RBAC chỉ kiểm tra quyền thao tác. Nếu alice có quyền create Pod, RBAC không biết Pod đó có chạy root hay dùng image latest không. Gatekeeper kiểm nội dung manifest, nên hai lớp này bổ sung cho nhau.

### Vì sao không commit secret vào Git?

Vì Git có lịch sử commit. Lỡ commit secret rồi xóa vẫn có thể bị lộ trong history. ESO giúp repo chỉ chứa cách sync secret, còn secret thật nằm ở AWS Secrets Manager.

### Vì sao image phải ký?

Vì tag image có thể bị thay đổi hoặc image có thể bị push nhầm. Cosign signature giúp cluster xác minh image đúng là image được pipeline tin cậy ký.

### Vì sao payments cần namespace riêng?

Để cô lập quyền, tài nguyên và network. Nếu payments dùng chung namespace `demo`, RBAC/quota/netpol sẽ khó tách theo team.

### Vì sao NetworkPolicy phải cho DNS?

Nếu chặn toàn bộ egress mà không mở DNS, Pod không resolve được service name như `api.demo.svc.cluster.local`. Vì vậy policy chặn gọi chéo nhưng vẫn cho DNS port 53.

### Vì sao `constraints-warn` vẫn giữ lại?

Đây là bước audit an toàn. Khi mới bật policy trên platform đang chạy, dùng warn để xem resource nào vi phạm trước. Sau khi sạch mới chuyển sang `constraints` deny để tránh tự làm sập platform.
