# Giải thích chi tiết từng file YAML

Tài liệu này giải thích từng field có ý nghĩa trong các file YAML của lab
`w9-lab-gitops-final`. Thứ tự giải thích đi từ GitOps control plane tới ứng
dụng, observability, canary và CI.

## 1. Cách đọc YAML Kubernetes

Phần lớn Kubernetes manifest đều có bốn khối cơ bản:

```yaml
apiVersion: ...
kind: ...
metadata:
  ...
spec:
  ...
```

- `apiVersion`: API group và phiên bản mà Kubernetes dùng để hiểu resource.
- `kind`: loại resource cần tạo, ví dụ `Service`, `Deployment`, `Rollout`.
- `metadata`: danh tính và thông tin mô tả resource.
- `metadata.name`: tên duy nhất của resource trong một namespace.
- `metadata.namespace`: namespace chứa resource.
- `metadata.labels`: dữ liệu key-value dùng để chọn và nhóm resource.
- `metadata.annotations`: metadata dành cho controller hoặc công cụ mở rộng.
- `spec`: desired state, tức trạng thái mong muốn của resource.
- `---`: ngăn cách nhiều resource trong cùng một file YAML.
- `|`: bắt đầu một chuỗi nhiều dòng, giữ nguyên xuống dòng.
- Dấu `-`: một phần tử trong danh sách YAML.

Resource thuộc Kubernetes core thường dùng `apiVersion: v1`. Resource mở rộng
do controller khác cung cấp dùng API group riêng:

- `argoproj.io/v1alpha1`: ArgoCD Application, Argo Rollouts và AnalysisTemplate.
- `monitoring.coreos.com/v1`: ServiceMonitor và PrometheusRule.
- `apps/v1`: Deployment.

## 2. ArgoCD App-of-Apps

### `argocd/root.yaml`

> **File này làm gì?** Tạo Application gốc `root` để ArgoCD theo dõi thư mục `argocd/apps` trên Git, từ đó tạo và đồng bộ toàn bộ Application con của lab.
>
> **Kết quả mong đợi:** Backend, frontend, monitoring và Argo Rollouts xuất hiện trên ArgoCD và được quản lý theo desired state trong Git.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
```

- `argoproj.io/v1alpha1` cho biết resource này thuộc CRD của ArgoCD.
- `kind: Application` yêu cầu ArgoCD quản lý một nguồn Git và đồng bộ nó vào
  một destination Kubernetes.

```yaml
metadata:
  name: root
  namespace: argocd
```

- `name: root` đặt tên Application mẹ là `root`.
- `namespace: argocd` bắt buộc vì ArgoCD controller theo dõi Application trong
  namespace này.

```yaml
spec:
  project: default
```

- `spec` bắt đầu desired state của Application.
- `project: default` đặt Application vào ArgoCD Project mặc định. Project kiểm
  soát repository và cluster nào Application được phép truy cập.

```yaml
  source:
    repoURL: https://github.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2.git
    targetRevision: main
    path: cloud/w9/w9-lab-gitops-final/argocd/apps
    directory:
      recurse: true
```

- `source` mô tả nơi chứa desired state.
- `repoURL` là Git repository ArgoCD sẽ pull.
- `targetRevision: main` yêu cầu ArgoCD luôn đọc branch `main`.
- `path` giới hạn nguồn vào thư mục chứa các Application con.
- `directory` cấu hình cách ArgoCD đọc thư mục thường.
- `recurse: true` yêu cầu tìm manifest trong cả thư mục con, không chỉ cấp đầu.

```yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
```

- `destination` mô tả nơi apply resource.
- `server: https://kubernetes.default.svc` là API Server của chính cluster đang
  chạy ArgoCD.
- `namespace: argocd` là namespace mặc định cho manifest không tự khai báo
  namespace. Các Application con cũng nằm trong `argocd`.

```yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

- `syncPolicy` cấu hình cách đồng bộ.
- `automated` bật auto-sync, không cần bấm Sync mỗi lần Git thay đổi.
- `prune: true` xóa resource trong cluster nếu resource đó bị xóa khỏi Git.
- `selfHeal: true` sửa drift nếu resource bị chỉnh tay trong cluster.

**Kết quả:** apply `root.yaml` một lần sẽ bootstrap toàn bộ App-of-Apps.

### `argocd/apps/kube-prometheus-stack.yaml`

> **File này làm gì?** Yêu cầu ArgoCD dùng Helm chart để cài Prometheus, Grafana, Alertmanager và Prometheus Operator vào cluster.
>
> **Kết quả mong đợi:** Cluster có thể thu thập metric, hiển thị dashboard, đánh giá alert rule và gửi cảnh báo.

```yaml
metadata:
  name: kube-prometheus-stack
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "-2"
```

- Tạo child Application tên `kube-prometheus-stack`.
- Application vẫn nằm trong namespace `argocd`.
- `sync-wave: "-2"` yêu cầu root sync monitoring trước các Application có wave
  cao hơn.

```yaml
spec:
  project: default
  source:
    repoURL: https://prometheus-community.github.io/helm-charts
    chart: kube-prometheus-stack
    targetRevision: 65.1.1
```

- `repoURL` lần này là Helm repository, không phải Git repository.
- `chart` chọn chart `kube-prometheus-stack`.
- `targetRevision` khóa phiên bản chart ở `65.1.1`, tránh tự đổi phiên bản.

```yaml
    helm:
      values: |
```

- `helm` khai báo override cho chart.
- `values: |` bắt đầu một khối Helm values nhiều dòng.

```yaml
        defaultRules:
          create: false
```

- Không tạo bộ alert rules mặc định rất lớn của chart.
- Lab chỉ dùng rules tự viết cho Flipkart để tiết kiệm tài nguyên.

```yaml
        kubeApiServer:
          enabled: false
        kubeControllerManager:
          enabled: false
        coreDns:
          enabled: false
        kubeEtcd:
          enabled: false
        kubeScheduler:
          enabled: false
        kubeProxy:
          enabled: false
        kubelet:
          enabled: false
```

- Mỗi `enabled: false` tắt một monitor Kubernetes platform mặc định.
- Các monitor này hữu ích trong production nhưng không cần cho mục tiêu lab
  đo backend, đồng thời tiêu tốn RAM của Minikube.

```yaml
        kube-state-metrics:
          enabled: false
        prometheus-node-exporter:
          enabled: false
```

- Tắt kube-state-metrics và node-exporter.
- Lab vì vậy không tập trung vào metric node/cluster, chỉ giữ metric ứng dụng.

```yaml
        prometheusOperator:
          resources:
            requests:
              cpu: 50m
              memory: 100Mi
            limits:
              cpu: 200m
              memory: 256Mi
```

- Cấu hình tài nguyên cho Prometheus Operator.
- `requests` là lượng scheduler dùng để quyết định nơi đặt Pod.
- `limits` là mức tối đa container được phép sử dụng.
- `50m` CPU bằng 5% của một CPU core.
- `Mi` là mebibyte.

```yaml
        prometheus:
          prometheusSpec:
            retention: 6h
            serviceMonitorSelectorNilUsesHelmValues: false
            ruleSelectorNilUsesHelmValues: false
```

- `retention: 6h` chỉ giữ metric trong 6 giờ để tiết kiệm disk/RAM.
- `serviceMonitorSelectorNilUsesHelmValues: false` cho phép Prometheus chọn
  ServiceMonitor ngoài các label mặc định của Helm chart.
- `ruleSelectorNilUsesHelmValues: false` cho phép đọc PrometheusRule do
  Flipkart tạo.

Khối `prometheusSpec.resources` tiếp theo đặt request/limit cho Prometheus.
Khối `grafana.resources` làm điều tương tự cho Grafana.

```yaml
        alertmanager:
          config:
            global:
              resolve_timeout: 5m
```

- `alertmanager.config` là cấu hình Alertmanager thực tế.
- `resolve_timeout: 5m` là thời gian Alertmanager dùng để đánh dấu alert đã
  resolved nếu nguồn alert không tiếp tục cập nhật.

```yaml
              smtp_from: kienl8890@gmail.com
              smtp_smarthost: smtp.gmail.com:587
              smtp_hello: gmail.com
              smtp_auth_username: kienl8890@gmail.com
              smtp_auth_identity: kienl8890@gmail.com
              smtp_auth_password_file: /etc/alertmanager/secrets/flipkart-alertmanager-smtp/smtp-password
              smtp_require_tls: true
```

- `smtp_from`: địa chỉ hiển thị ở trường From.
- `smtp_smarthost`: Gmail SMTP server và port STARTTLS.
- `smtp_hello`: hostname dùng khi bắt tay SMTP.
- `smtp_auth_username` và `smtp_auth_identity`: tài khoản xác thực.
- `smtp_auth_password_file`: đọc App Password từ file Secret mount, không ghi
  password trực tiếp trong Git.
- `smtp_require_tls: true`: bắt buộc mã hóa TLS.

```yaml
            route:
              receiver: email-alerts
              group_by:
                - alertname
                - namespace
                - service
              group_wait: 10s
              group_interval: 1m
              repeat_interval: 30m
```

- `route` là cây định tuyến alert.
- `receiver: email-alerts` là receiver mặc định.
- `group_by` gom các alert có cùng alert name, namespace và service thành một
  notification.
- `group_wait: 10s` đợi 10 giây để gom thêm alert trước email đầu tiên.
- `group_interval: 1m` chờ ít nhất một phút trước khi gửi cập nhật nhóm.
- `repeat_interval: 30m` gửi lại alert còn firing sau mỗi 30 phút.

```yaml
              routes:
                - matchers:
                    - severity="critical"
                  receiver: email-alerts
                - matchers:
                    - severity="warning"
                  receiver: email-alerts
```

- Hai route con chọn alert theo label `severity`.
- Cả critical và warning hiện đều gửi tới email.

```yaml
            receivers:
              - name: email-alerts
                email_configs:
                  - to: kienl8890@gmail.com
                    send_resolved: true
```

- Khai báo receiver tên `email-alerts`.
- `to` là địa chỉ nhận.
- `send_resolved: true` gửi thêm email khi sự cố kết thúc.

```yaml
            inhibit_rules:
              - source_matchers:
                  - severity="critical"
                target_matchers:
                  - severity="warning"
                equal:
                  - alertname
                  - namespace
                  - service
```

- Inhibition tránh gửi warning nếu đã có critical tương ứng.
- Chỉ inhibit khi hai alert có cùng `alertname`, `namespace`, `service`.

```yaml
          alertmanagerSpec:
            secrets:
              - flipkart-alertmanager-smtp
```

- Yêu cầu Operator mount Secret `flipkart-alertmanager-smtp` vào Alertmanager.
- File password trong Secret trở thành đường dẫn được cấu hình ở trên.

```yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
```

- Cài chart vào cluster hiện tại, namespace `monitoring`.

```yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

- Tự sync, prune và self-heal.
- `CreateNamespace=true` tự tạo namespace `monitoring`.
- `ServerSideApply=true` giúp apply các CRD lớn của monitoring stack.

### `argocd/apps/argo-rollouts.yaml`

> **File này làm gì?** Cài Argo Rollouts controller và các CRD cần thiết để Kubernetes hiểu `Rollout`, `AnalysisTemplate` và `AnalysisRun`.
>
> **Kết quả mong đợi:** Cluster có thể triển khai canary, pause, promote và tự động abort dựa trên metric.

Các field Application chung có ý nghĩa giống `root.yaml`.

```yaml
annotations:
  argocd.argoproj.io/sync-wave: "-1"
```

- Cài Argo Rollouts sau monitoring wave `-2`, trước backend wave `0`.

```yaml
ignoreDifferences:
  - group: apiextensions.k8s.io
    kind: CustomResourceDefinition
    jqPathExpressions:
      - .spec
      - .metadata.annotations
      - .metadata.managedFields
```

- `ignoreDifferences` ngăn ArgoCD báo OutOfSync vì API Server tự biến đổi CRD.
- `group` và `kind` giới hạn rule vào CustomResourceDefinition.
- `jqPathExpressions` bỏ qua khác biệt trong spec, annotations và managedFields.

```yaml
source:
  repoURL: https://argoproj.github.io/argo-helm
  chart: argo-rollouts
  targetRevision: 2.37.7
```

- Cài Helm chart Argo Rollouts phiên bản cố định `2.37.7`.

Khối `helm.values.controller.resources` giới hạn tài nguyên controller.
Destination là namespace `argo-rollouts`; sync options tự tạo namespace và dùng
server-side apply.

### `argocd/apps/backend.yaml`

> **File này làm gì?** Tạo Application con `flipkart-backend`, theo dõi mọi manifest trong `flipkart/k8s/backend`.
>
> **Kết quả mong đợi:** MongoDB, backend, ServiceMonitor, alert rule, dashboard và cấu hình canary được ArgoCD tự động đồng bộ.

```yaml
metadata:
  name: flipkart-backend
  annotations:
    argocd.argoproj.io/sync-wave: "0"
```

- Child Application quản lý backend.
- Wave `0` chạy sau platform monitoring và Argo Rollouts.

```yaml
source:
  repoURL: https://github.com/X-BRAIN-CDO-09/LeHoangTrungKien-aws-accelerator-p2.git
  targetRevision: main
  path: cloud/w9/w9-lab-gitops-final/flipkart/k8s/backend
```

- ArgoCD pull branch `main` và đọc toàn bộ YAML backend trong path này.

```yaml
destination:
  server: https://kubernetes.default.svc
  namespace: flipkart
```

- Apply resource vào namespace `flipkart` của cluster hiện tại.

`automated`, `prune`, `selfHeal` và `CreateNamespace` lần lượt bật auto-sync,
xóa resource thừa, sửa drift và tự tạo namespace.

### `argocd/apps/frontend.yaml`

> **File này làm gì?** Tạo Application con `flipkart-frontend`, theo dõi và triển khai manifest trong `flipkart/k8s/frontend`.
>
> **Kết quả mong đợi:** Frontend được quản lý từ Git, tự đồng bộ và tự sửa khi có cấu hình bị thay đổi trực tiếp trong cluster.

File giống backend Application, nhưng:

- `name: flipkart-frontend`: tên Application frontend.
- `sync-wave: "1"`: triển khai sau backend.
- `path: .../flipkart/k8s/frontend`: đọc manifest frontend.

## 3. MongoDB và lưu trữ

### `flipkart/k8s/backend/mongodb.yaml`

> **File này làm gì?** Tạo vùng lưu trữ, Deployment và Service cho MongoDB để backend có database nội bộ.
>
> **Kết quả mong đợi:** Backend kết nối được tới MongoDB qua DNS Service và dữ liệu vẫn còn khi Pod MongoDB được tạo lại.

#### PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: flipkart-mongodb-data
  namespace: flipkart
  annotations:
    argocd.argoproj.io/sync-wave: "-2"
```

- Tạo PVC thuộc Kubernetes core API.
- PVC tên `flipkart-mongodb-data` nằm trong namespace `flipkart`.
- Wave `-2` tạo storage trước MongoDB.

```yaml
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

- `ReadWriteOnce` cho phép volume được mount read-write bởi một node.
- `requests.storage: 2Gi` yêu cầu 2 GiB persistent storage.

#### MongoDB Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flipkart-mongodb
  namespace: flipkart
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
```

- Tạo Deployment MongoDB sau PVC.

```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flipkart-mongodb
```

- Chỉ chạy một MongoDB Pod.
- Deployment quản lý Pod có label `app: flipkart-mongodb`.

```yaml
  template:
    metadata:
      labels:
        app: flipkart-mongodb
```

- `template` là mẫu Pod.
- Label Pod phải khớp selector của Deployment và Service.

```yaml
    spec:
      containers:
        - name: mongodb
          image: mongo:7.0
          imagePullPolicy: IfNotPresent
```

- Pod có một container tên `mongodb`.
- Dùng MongoDB image phiên bản 7.0.
- Chỉ pull image nếu node chưa có image đó.

```yaml
          ports:
            - name: mongodb
              containerPort: 27017
```

- Khai báo port MongoDB trong container.
- Đặt tên port giúp probe và Service tham chiếu bằng tên thay vì số.

```yaml
          readinessProbe:
            tcpSocket:
              port: mongodb
            initialDelaySeconds: 10
            periodSeconds: 10
```

- Readiness probe thử kết nối TCP tới port MongoDB.
- Đợi 10 giây sau khi container start, sau đó kiểm tra mỗi 10 giây.
- Pod chưa ready sẽ không nhận traffic từ Service.

```yaml
          livenessProbe:
            tcpSocket:
              port: mongodb
            initialDelaySeconds: 30
            periodSeconds: 20
```

- Liveness probe kiểm tra container còn sống.
- Nếu probe thất bại liên tục, kubelet restart container.

Khối `resources.requests` bảo đảm tài nguyên tối thiểu; `resources.limits` giới
hạn tối đa CPU/RAM MongoDB được dùng.

```yaml
          volumeMounts:
            - name: data
              mountPath: /data/db
```

- Mount volume tên `data` vào `/data/db`, nơi MongoDB lưu dữ liệu.

```yaml
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: flipkart-mongodb-data
```

- Volume `data` lấy storage từ PVC đã tạo.
- Pod bị xóa/tạo lại nhưng PVC vẫn giữ dữ liệu.

#### MongoDB Service

```yaml
kind: Service
metadata:
  name: flipkart-mongodb
```

- Tạo DNS nội bộ `flipkart-mongodb.flipkart.svc.cluster.local`.

```yaml
spec:
  selector:
    app: flipkart-mongodb
  ports:
    - name: mongodb
      port: 27017
      targetPort: mongodb
```

- Service chọn MongoDB Pod theo label.
- `port` là port Service cung cấp.
- `targetPort: mongodb` chuyển traffic tới container port có tên `mongodb`.

## 4. Backend stable/canary

### `flipkart/k8s/backend/backend-services.yaml`

> **File này làm gì?** Tạo Service stable và Service canary để Argo Rollouts có thể tách traffic giữa phiên bản đang ổn định và phiên bản đang kiểm thử.
>
> **Kết quả mong đợi:** Người dùng đi qua stable Service, còn load test và AnalysisRun có thể đánh giá riêng canary Service.

File chứa hai Service.

#### Stable Service

```yaml
metadata:
  name: flipkart-backend
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
  labels:
    app: flipkart-backend
    role: stable
```

- `flipkart-backend` là endpoint stable mà frontend gọi.
- Wave `-1` tạo Service trước Rollout.
- Label `app` giúp ServiceMonitor tìm Service.
- Label `role: stable` mô tả vai trò.

```yaml
spec:
  selector:
    app: flipkart-backend
  ports:
    - name: http
      port: 4000
      targetPort: http
```

- Ban đầu chọn backend Pod theo label `app`.
- Argo Rollouts sẽ bổ sung selector hash để Service chỉ trỏ stable ReplicaSet.
- Service port `4000` chuyển tới container port tên `http`.

#### Canary Service

Resource thứ hai giống stable Service nhưng:

- `name: flipkart-backend-canary`: DNS dành riêng cho canary.
- `role: canary`: mô tả vai trò canary.
- Argo Rollouts cập nhật selector để chỉ trỏ tới canary ReplicaSet.

### `flipkart/k8s/backend/backend-rollout.yaml`

> **File này làm gì?** Thay Deployment thông thường bằng Rollout, đồng thời khai báo image, probe, tài nguyên và các bước phát hành canary.
>
> **Kết quả mong đợi:** Bản tốt được promote thành stable; bản có metric xấu bị dừng và abort trước khi nhận toàn bộ traffic.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
```

- Đây là CRD của Argo Rollouts, thay thế Deployment cho backend.

```yaml
metadata:
  name: flipkart-backend
  namespace: flipkart
  annotations:
    argocd.argoproj.io/sync-wave: "0"
  labels:
    app: flipkart-backend
```

- Tạo Rollout backend ở wave `0`, sau Service và MongoDB.

```yaml
spec:
  replicas: 4
  revisionHistoryLimit: 3
  minReadySeconds: 10
  progressDeadlineSeconds: 600
```

- Desired state là 4 Pod.
- Giữ tối đa 3 ReplicaSet cũ để rollback.
- Pod phải ready liên tục 10 giây mới được xem là available.
- Rollout có tối đa 600 giây để tiến triển trước khi bị đánh dấu lỗi.

```yaml
  selector:
    matchLabels:
      app: flipkart-backend
```

- Rollout quản lý Pod có label `app: flipkart-backend`.

```yaml
  template:
    metadata:
      labels:
        app: flipkart-backend
```

- Mọi Pod mới từ Rollout nhận label khớp selector.

```yaml
    spec:
      containers:
        - name: backend
          image: flipkart-backend:v2-good
          imagePullPolicy: IfNotPresent
```

- Pod chạy container backend.
- Image tag bất biến mô tả phiên bản good.
- Minikube dùng image local nếu đã tồn tại.

```yaml
          ports:
            - name: http
              containerPort: 4000
```

- Backend nghe port `4000`, được đặt tên `http`.

```yaml
          env:
            - name: NODE_ENV
              value: production
            - name: PORT
              value: "4000"
            - name: APP_VERSION
              value: "v2-good"
            - name: ERROR_RATE
              value: "0"
            - name: MONGO_URI
              value: mongodb://flipkart-mongodb:27017/flipkart
```

- `NODE_ENV`: chạy Node.js ở production mode.
- `PORT`: port backend lắng nghe.
- `APP_VERSION`: gắn version vào `/healthz` và metric.
- `ERROR_RATE`: xác suất inject lỗi; `0` nghĩa là không inject.
- `MONGO_URI`: kết nối MongoDB qua Kubernetes Service DNS.

```yaml
          envFrom:
            - secretRef:
                name: flipkart-backend-secrets
```

- Nạp tất cả key trong Secret thành biến môi trường.
- Secret chứa cấu hình nhạy cảm và không được commit vào Git.

```yaml
          readinessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
```

- Gọi `/healthz` sau 10 giây, lặp mỗi 10 giây.
- Chỉ Pod ready mới nhận traffic.

```yaml
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 30
            periodSeconds: 15
```

- Kiểm tra ứng dụng còn sống; thất bại kéo dài sẽ restart container.

Khối `resources` đặt request `100m/256Mi` và limit `500m/512Mi`.

```yaml
  strategy:
    canary:
      stableService: flipkart-backend
      canaryService: flipkart-backend-canary
      maxSurge: 1
      maxUnavailable: 0
```

- Chọn chiến lược canary.
- Khai báo Service stable và canary để controller quản lý selector.
- `maxSurge: 1` cho phép tạo thêm tối đa một Pod ngoài desired replicas.
- `maxUnavailable: 0` không cho phép giảm số Pod available trong rollout.

```yaml
      steps:
        - setWeight: 25
        - pause: {}
        - setWeight: 50
        - pause:
            duration: 30s
        - analysis:
            templates:
              - templateName: flipkart-backend-quality
        - setWeight: 100
```

- Bước 1 đưa canary lên 25%.
- `pause: {}` dừng vô thời hạn, cần promote thủ công.
- Sau promote, tăng canary lên 50%.
- Dừng 30 giây để có metric.
- Chạy AnalysisTemplate `flipkart-backend-quality`.
- Analysis thành công thì đưa canary lên 100% và trở thành stable.

## 5. Prometheus scrape, SLI và alert

### `flipkart/k8s/backend/backend-servicemonitor.yaml`

> **File này làm gì?** Chỉ cho Prometheus Operator biết Service backend nào cần được scrape và endpoint metric nằm tại `/metrics`.
>
> **Kết quả mong đợi:** Target backend hiển thị `UP` trong Prometheus và các metric `flipkart_*` có thể query được.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
```

- CRD do Prometheus Operator cung cấp.
- Mô tả Service nào và endpoint nào Prometheus cần scrape.

```yaml
metadata:
  name: flipkart-backend
  namespace: flipkart
  labels:
    app: flipkart-backend
```

- ServiceMonitor nằm cùng namespace ứng dụng.
- Label giúp nhận diện resource.

```yaml
spec:
  namespaceSelector:
    matchNames:
      - flipkart
```

- Chỉ tìm Service trong namespace `flipkart`.

```yaml
  selector:
    matchLabels:
      app: flipkart-backend
```

- Chọn cả stable và canary Service vì cả hai đều có label này.

```yaml
  endpoints:
    - port: http
      path: /metrics
      interval: 15s
      scrapeTimeout: 10s
```

- Scrape port Service có tên `http`.
- Gọi path `/metrics`.
- Thu thập mỗi 15 giây.
- Hủy scrape nếu backend không trả lời trong 10 giây.

### `flipkart/k8s/backend/backend-prometheus-rules.yaml`

> **File này làm gì?** Khai báo recording rules và alert rules để tính traffic, error ratio, success ratio, latency và burn rate.
>
> **Kết quả mong đợi:** Các metric tổng hợp query được; cảnh báo chuyển sang `Pending` hoặc `Firing` khi chất lượng backend vượt ngưỡng lỗi.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
```

- CRD chứa recording rules và alert rules cho Prometheus.

```yaml
spec:
  groups:
    - name: flipkart-backend.sli.recording
      interval: 15s
      rules:
```

- Nhóm đầu tiên tính SLI.
- Prometheus đánh giá rules mỗi 15 giây.

```yaml
- record: flipkart_backend:http_requests:rate2m
  expr: sum(rate(flipkart_http_requests_total[2m]))
```

- `rate(...[2m])` tính tốc độ tăng counter trung bình trong 2 phút.
- `sum` cộng traffic của mọi Pod/version.
- `record` lưu kết quả thành metric mới để dashboard query nhanh hơn.

Ba rules `http_errors:ratio_rate2m`, `ratio_rate5m`, `ratio_rate15m` dùng cùng
công thức:

```promql
(
  sum(rate(flipkart_http_requests_total{status_code=~"5.."}[window]))
  or vector(0)
)
/
clamp_min(sum(rate(flipkart_http_requests_total[window])), 1e-9)
```

- `{status_code=~"5.."}` chỉ chọn HTTP 5xx.
- Tử số là tốc độ request lỗi.
- Mẫu số là tốc độ toàn bộ request.
- `or vector(0)` trả `0` khi chưa có request lỗi.
- `clamp_min(..., 1e-9)` tránh chia cho 0.
- Các cửa sổ 2/5/15 phút phục vụ đánh giá nhanh và dài hạn.

```yaml
- record: flipkart_backend:http_success:ratio_rate5m
  expr: 1 - flipkart_backend:http_errors:ratio_rate5m
```

- Success ratio bằng `1 - error ratio`.

```yaml
- record: flipkart_backend:http_request_duration_seconds:p95_rate5m
```

- `histogram_quantile(0.95, ...)` tìm latency mà 95% request nhanh hơn giá trị
  đó.
- `sum by (le)` giữ label bucket boundary cần thiết cho histogram.

```yaml
- record: flipkart_backend:error_budget:burn_rate5m
  expr: flipkart_backend:http_errors:ratio_rate5m / 0.005
```

- SLO availability 99.5% cho phép error budget 0.5%, tức `0.005`.
- Error ratio chia `0.005` cho biết tốc độ tiêu hao error budget.
- Rule 15 phút làm tương tự với cửa sổ dài hơn.

Nhóm `flipkart-backend.slo.alerts` chứa ba alert:

```yaml
- alert: FlipkartBackendFastBurn
  expr: error_ratio_2m > 0.10 and error_ratio_5m > 0.10
  for: 1m
```

- Firing nếu cả cửa sổ 2 và 5 phút đều vượt 10% liên tục một phút.
- `severity: critical` dùng để route Alertmanager.
- `service` và `slo` bổ sung ngữ cảnh.
- `annotations.summary/description` là nội dung con người đọc.

```yaml
- alert: FlipkartBackendSlowBurn
  expr: error_ratio_5m > 0.03 and error_ratio_15m > 0.03
  for: 3m
```

- Phát hiện lỗi nhỏ hơn nhưng kéo dài.
- Dùng `severity: warning`.

```yaml
- alert: FlipkartBackendHighP95Latency
  expr: p95_latency > 0.5
  for: 3m
```

- Firing nếu p95 latency vượt 500 ms liên tục 3 phút.

## 6. AnalysisTemplate đánh giá canary

### `flipkart/k8s/backend/backend-analysis-template.yaml`

> **File này làm gì?** Cung cấp mẫu phân tích để Argo Rollouts query Prometheus và đánh giá chất lượng phiên bản canary.
>
> **Kết quả mong đợi:** Analysis thành công cho phép rollout tiếp tục; Analysis thất bại khiến rollout tự động abort.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: flipkart-backend-quality
  namespace: flipkart
```

- Template do Argo Rollouts sử dụng để tạo AnalysisRun.
- Tên phải khớp `templateName` trong Rollout.

```yaml
spec:
  args:
    - name: prometheus-address
      value: http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090
```

- Khai báo argument địa chỉ Prometheus nội bộ.
- DNS đầy đủ đi từ Service `kube-prometheus-stack-prometheus` trong namespace
  `monitoring` tới port `9090`.

Mỗi phần tử trong `metrics` có cấu trúc:

```yaml
- name: ...
  interval: 30s
  count: 4
  failureLimit: 2
  successCondition: ...
  failureCondition: ...
  provider:
    prometheus:
      address: "{{args.prometheus-address}}"
      query: |
        ...
```

- `name`: tên phép đo trong AnalysisRun.
- `interval: 30s`: chạy query mỗi 30 giây.
- `count: 4`: chạy tối đa 4 lần.
- `failureLimit: 2`: thất bại khi số lần fail vượt 2.
- `successCondition`: biểu thức Argo Rollouts dùng để đánh dấu lần đo đạt.
- `failureCondition`: biểu thức đánh dấu lần đo thất bại.
- `provider.prometheus`: query dữ liệu từ Prometheus.
- `address`: lấy từ argument đã khai báo.
- `query`: PromQL cần chạy.

#### `canary-request-rate`

- Query chỉ chọn `service="flipkart-backend-canary"`.
- Điều kiện thành công yêu cầu có kết quả và ít nhất `0.1 request/giây`.
- Điều kiện này ngăn promote một canary chưa thực sự nhận traffic.

#### `success-rate`

```promql
1 - (canary_5xx_rate / canary_total_rate)
```

- Chỉ tính request của canary Service.
- `status_code=~"5.."` chọn lỗi server.
- `or vector(0)` xử lý trường hợp chưa có lỗi.
- `clamp_min(..., 1e-9)` tránh chia cho 0.
- Canary đạt khi success rate ít nhất 95%.

#### `p95-latency`

- Tính p95 từ histogram bucket của canary Service trong 2 phút.
- Canary đạt khi p95 nhỏ hơn hoặc bằng `0.5` giây.

**Kết quả:** nếu một metric vượt failure limit, AnalysisRun thất bại và Rollout
tự động abort revision mới.

## 7. Grafana dashboard

### `flipkart/k8s/backend/backend-grafana-dashboard.yaml`

> **File này làm gì?** Tạo ConfigMap chứa dashboard JSON để Grafana sidecar tự động import dashboard theo dõi backend.
>
> **Kết quả mong đợi:** Grafana hiển thị dashboard traffic, error ratio, latency và burn rate mà không cần tạo panel thủ công.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: flipkart-backend-dashboard
  namespace: monitoring
  annotations:
    argocd.argoproj.io/sync-wave: "1"
  labels:
    grafana_dashboard: "1"
    app: flipkart-backend
```

- Dashboard được lưu dưới dạng ConfigMap trong namespace `monitoring`.
- Wave `1` tạo dashboard sau các resource backend wave `0`.
- Label `grafana_dashboard: "1"` giúp Grafana sidecar tự phát hiện và import.

```yaml
data:
  flipkart-backend.json: |
```

- Key `flipkart-backend.json` trở thành tên file dashboard.
- Giá trị bên dưới là JSON nhiều dòng theo schema Grafana.

Các field JSON lặp lại trong mỗi panel:

- `datasource.type: prometheus`: panel query Prometheus.
- `datasource.uid: prometheus`: chọn datasource có UID `prometheus`.
- `fieldConfig.defaults`: cách hiển thị và threshold mặc định.
- `thresholds.steps`: đổi màu theo ngưỡng.
- `gridPos`: vị trí và kích thước panel trên dashboard.
- `options`: kiểu hiển thị, legend, tooltip và cách reduce dữ liệu.
- `targets`: danh sách query.
- `expr`: PromQL.
- `legendFormat`: tên hiển thị trong legend.
- `title`: tiêu đề panel.
- `type`: kiểu panel như `stat`, `gauge`, `timeseries`.

Sáu panel:

| Panel | Query | Ý nghĩa |
|---|---|---|
| Backend Request Rate | `flipkart_backend:http_requests:rate2m` | Request/giây |
| Availability SLI | `flipkart_backend:http_success:ratio_rate5m` | Tỷ lệ thành công |
| Error Ratio | `flipkart_backend:http_errors:ratio_rate5m` | Tỷ lệ lỗi |
| P95 Latency | `flipkart_backend:http_request_duration_seconds:p95_rate5m` | P95 latency |
| Traffic by Version and Status | `sum by (version, status_code) (...)` | So sánh stable/canary và HTTP status |
| Error Budget Burn Rate | burn rate 5m và 15m | Tốc độ tiêu hao error budget |

Dashboard-level fields:

- `refresh: "10s"`: tự refresh mỗi 10 giây.
- `time.from: "now-30m"`: mặc định hiển thị 30 phút gần nhất.
- `time.to: "now"`: kết thúc ở hiện tại.
- `timezone: "browser"`: dùng múi giờ trình duyệt.
- `title`: tên dashboard.
- `uid`: ID ổn định để Grafana cập nhật đúng dashboard cũ.
- `version`: phiên bản dashboard JSON.

## 8. Frontend

### `flipkart/k8s/frontend/frontend.yaml`

> **File này làm gì?** Tạo cấu hình Nginx, Deployment và Service cho frontend, đồng thời proxy request `/api/` tới backend stable.
>
> **Kết quả mong đợi:** Giao diện truy cập được, Pod frontend sẵn sàng và lời gọi API đi đúng tới backend.

#### Nginx ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: flipkart-frontend-nginx
  namespace: flipkart
data:
  default.conf: |
```

- Lưu file cấu hình Nginx `default.conf` trong ConfigMap.

```nginx
server {
  listen 80;
  server_name _;
```

- Nginx nghe port 80 và chấp nhận mọi hostname.

```nginx
location /api/ {
  proxy_pass http://flipkart-backend:4000;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

- Request `/api/*` được proxy tới stable backend Service.
- Các header giữ thông tin hostname, IP client, chuỗi proxy và protocol gốc.

```nginx
location / {
  root /usr/share/nginx/html;
  try_files $uri $uri/ /index.html;
}
```

- Phục vụ React static files.
- Nếu đường dẫn không phải file thật, trả `index.html` để React Router xử lý.

#### Frontend Deployment

- `replicas: 2`: chạy hai frontend Pod.
- `selector.matchLabels` phải khớp `template.metadata.labels`.
- Image frontend lấy từ Docker Hub.
- `imagePullPolicy: IfNotPresent` dùng image local nếu có.
- Container mở port tên `http` tại port 80.
- Readiness probe gọi `/` sau 5 giây, mỗi 10 giây.
- Liveness probe gọi `/` sau 15 giây, mỗi 15 giây.
- Resource request/limit bảo vệ tài nguyên cluster.

```yaml
volumeMounts:
  - name: nginx-config
    mountPath: /etc/nginx/conf.d/default.conf
    subPath: default.conf
```

- Mount đúng key `default.conf` từ ConfigMap vào đúng file cấu hình Nginx.
- `subPath` tránh mount đè toàn bộ thư mục `/etc/nginx/conf.d`.

```yaml
volumes:
  - name: nginx-config
    configMap:
      name: flipkart-frontend-nginx
```

- Tạo volume từ ConfigMap đã khai báo.

#### Frontend Service

- Service chọn Pod có label `app: flipkart-frontend`.
- Mở port 80 và chuyển tới container port tên `http`.
- Không khai báo `type`, nên mặc định là `ClusterIP`.

## 9. Canary load test

### `obs-canary/load-test/backend-canary-load.yaml`

> **File này làm gì?** Tạo một Pod BusyBox gửi request liên tục tới Service canary để sinh dữ liệu đánh giá phiên bản mới.
>
> **Kết quả mong đợi:** Prometheus có đủ metric canary để AnalysisRun quyết định promote hoặc abort. File này hiện được apply thủ công, không nằm trong đường dẫn ArgoCD quản lý.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend-canary-load
  namespace: flipkart
  labels:
    app: backend-canary-load
```

- Tạo một Pod đơn giản chuyên sinh traffic trong namespace Flipkart.

```yaml
spec:
  restartPolicy: Always
```

- Kubelet luôn restart container nếu process kết thúc.

```yaml
containers:
  - name: load
    image: busybox:1.36
    command:
      - sh
      - -c
      - |
```

- Dùng BusyBox nhẹ.
- Chạy shell với command string nhiều dòng.

```sh
while true; do
  wget -qO- http://flipkart-backend-canary:4000/api/v1/products >/dev/null || true
  sleep 0.2
done
```

- Vòng lặp chạy vô hạn.
- Gửi request trực tiếp vào canary Service.
- `-qO-` chạy im lặng và ghi response ra stdout.
- `>/dev/null` bỏ nội dung response.
- `|| true` giữ loop chạy dù request lỗi.
- `sleep 0.2` tạo khoảng 5 request/giây.

Khối resources đặt request rất nhỏ và giới hạn Pod load ở `100m CPU/32Mi RAM`.

## 10. Demo sync waves

### `k8s/namespace.yaml`

> **File này làm gì?** Tạo namespace `demo` ở sync wave `-1` để minh họa resource nền tảng phải tồn tại trước workload.
>
> **Kết quả mong đợi:** Namespace `demo` được tạo trước các resource trong `k8s/web.yaml`. Đây là phần demo, không thuộc flow Flipkart chính.

- `apiVersion: v1`, `kind: Namespace`: tạo namespace.
- `name: demo`: namespace tên `demo`.
- `sync-wave: "-1"`: tạo namespace trước workload demo.

### `k8s/web.yaml`

> **File này làm gì?** Tạo ConfigMap, Deployment và Service cho ứng dụng Nginx demo theo nhiều sync wave.
>
> **Kết quả mong đợi:** Thấy rõ thứ tự đồng bộ, desired state và khả năng tự sửa drift của GitOps. Đây là phần demo, không thuộc flow Flipkart chính.

#### ConfigMap wave 0

- Tạo ConfigMap `web-config` trong namespace `demo`.
- `MESSAGE` là biến cấu hình mẫu.

#### Deployment wave 1

- Tạo Deployment `web` sau ConfigMap.
- Chạy 2 replica Nginx `1.27`.
- Selector và Pod label cùng là `app: web`.
- `envFrom.configMapRef` nạp mọi key của `web-config` thành biến môi trường.

#### Service wave 2

- Tạo Service sau Deployment.
- Chọn Pod `app: web`.
- Mở Service port 80 và chuyển tới container port 80.

Thứ tự hoàn chỉnh:

```text
Namespace -1 -> ConfigMap 0 -> Deployment 1 -> Service 2
```

## 11. GitHub Actions YAML

### `.github/workflows/w9-gitops-validate.yml`

> **File này làm gì?** Định nghĩa GitHub Actions workflow chạy `kubeconform` để kiểm tra manifest trước khi thay đổi được merge.
>
> **Kết quả mong đợi:** YAML hợp lệ vượt qua CI; manifest sai schema làm workflow thất bại và cảnh báo người review. File này không tạo resource Kubernetes.

```yaml
name: W9 GitOps Manifest Validation
```

- Tên workflow hiển thị trên GitHub Actions.

```yaml
on:
  pull_request:
    branches:
      - main
    paths:
      - ...
  workflow_dispatch:
```

- Chạy khi Pull Request hướng vào `main` và thay đổi một path được liệt kê.
- `workflow_dispatch` cho phép chạy tay từ GitHub UI.

```yaml
permissions:
  contents: read
```

- Token của workflow chỉ được đọc repository, tuân thủ least privilege.

```yaml
jobs:
  validate:
    name: Validate Kubernetes and ArgoCD manifests
    runs-on: ubuntu-latest
```

- Tạo job ID `validate`.
- Job hiển thị tên mô tả và chạy trên GitHub-hosted Ubuntu runner.

```yaml
steps:
  - name: Checkout repository
    uses: actions/checkout@v4
```

- Checkout source code vào runner.

Step `Install kubeconform`:

- `curl -sSLo`: tải archive kubeconform.
- `tar -xzf`: giải nén.
- `sudo mv`: đưa binary vào PATH.
- `kubeconform -v`: xác nhận cài thành công.

Ba step validate:

- `-strict`: từ chối field không được schema cho phép.
- `-summary`: in tổng kết pass/fail.
- Validate `k8s/`: manifest Kubernetes demo dùng schema chuẩn.
- Validate `flipkart/k8s/` với `-ignore-missing-schemas`: bỏ qua CRD như
  Rollout, ServiceMonitor, PrometheusRule nếu schema không có.
- Validate `argocd/` với `-ignore-missing-schemas`: bỏ qua schema Application
  CRD chưa có trong bộ schema mặc định.

Workflow chỉ validate YAML; nó không apply resource. ArgoCD vẫn chịu trách
nhiệm CD sau khi Pull Request được merge.

## 12. Quan hệ giữa các file

```text
root.yaml
  -> đọc argocd/apps/
  -> cài kube-prometheus-stack
  -> cài argo-rollouts
  -> tạo backend Application
  -> tạo frontend Application

backend Application
  -> MongoDB PVC/Deployment/Service
  -> stable và canary Service
  -> backend Rollout
  -> ServiceMonitor
  -> PrometheusRule
  -> AnalysisTemplate
  -> Grafana dashboard

frontend Application
  -> Nginx ConfigMap
  -> frontend Deployment
  -> frontend Service

load-test Pod
  -> gọi canary Service
  -> backend sinh metric
  -> Prometheus scrape qua ServiceMonitor
  -> AnalysisRun query Prometheus
  -> Rollout promote hoặc abort
```

## 13. Các lỗi thường gặp khi chỉnh YAML

- `selector.matchLabels` không khớp Pod labels: Service/Deployment không tìm
  được Pod.
- Đổi tên port nhưng không đổi `targetPort`, probe hoặc ServiceMonitor: traffic
  và scrape bị lỗi.
- AnalysisTemplate query stable Service thay vì canary Service: metric stable
  che lấp lỗi canary.
- Không chạy load test: canary request rate bằng 0 và analysis thất bại.
- Dùng `latest` cho canary: khó xác định chính xác revision đang chạy.
- Push đổi path Git nhưng không apply lại root Application: root vẫn đọc path
  cũ và báo lỗi.
- Commit Secret/App Password vào Git: rò rỉ credential.
