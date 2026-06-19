# W10 - Progressive Delivery with Analysis

GitOps setup for API deployment với Argo Rollouts + AnalysisTemplate.

## Concept

Deploy API với **canary strategy** và **automated analysis**:
- Rollout: 10% → 50% → 100%
- AnalysisTemplate query Prometheus để check success rate ≥ 95%
- Auto rollback nếu analysis fail
- AlertManager gửi email khi có SLO violation

## Requirements

- Docker Desktop
- kubectl
- minikube
- git

## Structure

```
w10/
├── app-api/              # API Rollout manifests
│   ├── rollout.yaml      # Argo Rollout với canary strategy
│   ├── service.yaml      # Service expose API
│   └── servicemonitor.yaml # Prometheus metrics scraper
├── app-analysis/         # Analysis manifests
│   └── analysis-template.yaml # Template phân tích success rate
├── app-alert/            # Alert manifests
│   ├── prometheus-rules.yaml # PrometheusRule cho SLO alerts
│   ├── email-secret.yaml # Gmail password (NOT COMMITTED)
│   └── README.md         # Alert setup guide
├── app-common/           # Common resources
│   └── demo-namespace.yaml # Namespace demo
├── security-rbac-admission/ # RBAC + Gatekeeper lab from W10 morning
├── eso/                  # ESO SecretStore + ExternalSecret + demo consumer
├── signing/              # Cosign public key placeholder
├── policies/             # Sigstore ClusterImagePolicy
├── runbooks/             # Secret rotation + CVE exception runbooks
├── tenants/payments/     # Take-home tenant platform resources
├── apps/payments/        # Take-home team B workload
├── evidence/payments/    # Take-home evidence commands and test manifests
├── src/                  # Source code
│   └── api/              # Flask API application
├── argocd/
│   ├── apps/             # ArgoCD Application manifests
│   │   ├── app-api.yaml  # Deploy API Rollout
│   │   ├── app-analysis.yaml # Deploy AnalysisTemplate
│   │   ├── app-alert.yaml # Deploy PrometheusRule
│   │   ├── app-common.yaml # Deploy common resources
│   │   ├── k8s-prometheus.yaml # Prometheus + AlertManager
│   │   └── k8s-rollout.yaml # Argo Rollouts controller
│   └── root.yaml         # App of Apps pattern
└── README.md
```

## Quick Start

### 1. Setup Cluster
```bash
minikube start -p w10 --driver=docker
kubectl config use-context w10
```

### 2. Install ArgoCD
```bash
kubectl create ns argocd
kubectl apply --server-side -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server
```

### 3. Access ArgoCD UI
```bash
# Port forward
kubectl -n argocd port-forward svc/argocd-server 8080:443 &

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

### 4. Deploy App of Apps
```bash
kubectl apply -f argocd/root.yaml
```

### 4.1. Port-forward UI và API
```bash
cloud/w10/temp/scripts/port-forward-temp.sh all
```

Các mode riêng:

```bash
cloud/w10/temp/scripts/port-forward-temp.sh argocd
cloud/w10/temp/scripts/port-forward-temp.sh obs
cloud/w10/temp/scripts/port-forward-temp.sh app
```

Endpoints local:

```text
ArgoCD       https://localhost:8080
Grafana      http://localhost:3000
Prometheus   http://localhost:9090
Alertmanager http://localhost:9093
API          http://localhost:8081
```

### 4.2. Build API image

GitHub Actions workflow nằm ở root repo:

```text
.github/workflows/w10-temp-build-push.yml
```

Khi push thay đổi trong `cloud/w10/temp/src/api/**`, workflow sẽ build image và push lên GitHub Container Registry:

```text
ghcr.io/x-brain-cdo-09/lehoangtrungkien-aws-accelerator-p2/w10-api:<version>
```

Workflow chạy theo chuỗi:

```text
docker build -> Trivy HIGH/CRITICAL scan -> push GHCR -> Cosign sign -> update Rollout tag
```

Trước khi bật workflow ký image, tạo GitHub Secrets:

```text
COSIGN_PRIVATE_KEY
COSIGN_PASSWORD
```

Sau đó workflow tự cập nhật image tag trong:

```text
cloud/w10/temp/app-api/rollout.yaml
```

### 5. Setup Email Alert (Optional)
```bash
# Follow instructions in app-alert/README.md
cp app-alert/email-secret.yaml.example app-alert/email-secret.yaml
kubectl apply -f app-alert/email-secret.yaml
```

## Components

### Core
- **Argo Rollouts**: Progressive delivery controller
- **Prometheus Stack**: Metrics collection + AlertManager
- **API**: Flask application với metrics endpoint

### GitOps Applications
- `app-api`: API Rollout với canary strategy
- `app-analysis`: AnalysisTemplate cho automated validation
- `app-alert`: PrometheusRule cho runtime alerting
- `app-common`: Shared resources (namespace)
- `k8s-prometheus`: Monitoring stack
- `k8s-rollout`: Argo Rollouts controller
- `gatekeeper`: OPA Gatekeeper controller
- `security-rbac`: RBAC examples for demo namespace and cluster viewer
- `security-workload-identity`: ServiceAccount for the API Pod
- `security-gatekeeper-templates`: Gatekeeper ConstraintTemplates
- `security-gatekeeper-constraints`: Gatekeeper Constraints
- `external-secrets`: External Secrets Operator
- `eso-config`: SecretStore, ExternalSecret and secret consumer
- `sigstore-policy-controller`: Sigstore admission controller
- `supply-chain-policies`: ClusterImagePolicy for signed images
- `payments`: namespace, RBAC, quota, LimitRange and NetworkPolicy for team B
- `payments-app`: workload for team B

## Verify Deployment

### Check Rollout Status
```bash
# Watch rollout progress
kubectl get rollout api -n demo -w

# Check current state
kubectl get rollout api -n demo

# Check pods
kubectl get pods -n demo -l app=api
```

### Check AnalysisRun
```bash
# List analysis runs
kubectl get analysisrun -n demo

# Watch latest analysis
kubectl get analysisrun -n demo --sort-by=.metadata.creationTimestamp | tail -1

# Describe for detailed metrics
kubectl describe analysisrun -n demo <name>
```

### Query Prometheus Metrics
```bash
# Success rate metric
kubectl run test-query --image=curlimages/curl:latest --rm -i --restart=Never -n monitoring -- \
  curl -s 'http://kube-prometheus-stack-prometheus.monitoring.svc:9090/api/v1/query?query=api:success_rate:5m'
```

## Test Scenarios (GitOps)

### Test 1: Successful Deployment (Success Rate ≥ 90%)
```bash
# Edit rollout to deploy with no errors
nano app-api/rollout.yaml
# Set: ERROR_RATE: "0"

git add app-api/rollout.yaml
git commit -m "test: deploy with 0% error rate"
git push origin main

# Watch AnalysisRun succeed
kubectl get analysisrun -n demo -w
```

### Test 2: Failed Deployment (Success Rate < 90%)
```bash
# Edit rollout to deploy with 15% error rate
nano app-api/rollout.yaml
# Set: ERROR_RATE: "0.15"

git add app-api/rollout.yaml
git commit -m "test: deploy with 15% error rate (should fail)"
git push origin main

# Watch AnalysisRun fail and auto rollback
kubectl get analysisrun -n demo -w
kubectl get rollout api -n demo
```

### Test 3: Trigger SLO Alert Email
```bash
# Edit rollout to set 10% error rate (triggers alert, but passes canary)
nano app-api/rollout.yaml
# Set: ERROR_RATE: "0.10"

git add app-api/rollout.yaml
git commit -m "test: deploy with 10% error rate (90% success)"
git push origin main

# Canary passes (≥90%) but SLO alert fires (below 95%)
# Wait 2-3 minutes, then check email inbox
```


## Configuration Reference

### Sync Waves
ArgoCD applications deploy in order:
- Wave -1: `app-common` (namespace)
- Wave 0: `k8s-prometheus`, `k8s-rollout` (infrastructure)
- Wave 0: `gatekeeper` (admission controller)
- Wave 1: `app-analysis`, `app-alert`, `security-rbac`, `security-workload-identity`, `security-gatekeeper-templates` (configuration)
- Wave 1: `external-secrets` (ESO operator + CRDs)
- Wave 2: `security-gatekeeper-constraints`, `eso-config`, `app-api`
- Wave 3: `sigstore-policy-controller`
- Wave 4: `supply-chain-policies`
- Wave 5: `payments`
- Wave 6: `payments-app`

## W10 Morning: RBAC + Admission

Lab RBAC + Admission Policy nằm ở:

```text
security-rbac-admission/
```

Nội dung đã được quản lý bằng ArgoCD:

```text
argocd/apps/gatekeeper.yaml
argocd/apps/security-rbac.yaml
argocd/apps/security-workload-identity.yaml
argocd/apps/security-gatekeeper-templates.yaml
argocd/apps/security-gatekeeper-constraints.yaml
```

Xem hướng dẫn kiểm tra ở:

```text
security-rbac-admission/README.md
```

## W10 Afternoon: Secrets + Supply Chain

Lab buổi chiều nằm ở:

```text
eso/
signing/
policies/
runbooks/
```

### ESO

Không commit AWS credentials. Tạo Secret ngoài Git:

```bash
kubectl create secret generic aws-creds -n demo \
  --from-literal=access-key="$AWS_ACCESS_KEY_ID" \
  --from-literal=secret-key="$AWS_SECRET_ACCESS_KEY"
```

ArgoCD sẽ sync:

```text
eso/secret-store.yaml
eso/external-secret.yaml
eso/ghcr-pull-secret.yaml
eso/secret-consumer.yaml
```

Xem chi tiết ở:

```text
eso/README.md
runbooks/secret-rotation.md
```

### Trivy + Cosign + Admission Verify

Workflow root `.github/workflows/w10-temp-build-push.yml` scan image bằng Trivy và ký image bằng Cosign sau khi push GHCR.

Tạo key:

```bash
cosign generate-key-pair
```

Private key đưa vào GitHub Secrets, public key commit vào:

```text
signing/cosign.pub
policies/cluster-image-policy.yaml
```

Chỉ bật verify cho namespace `demo` sau khi image hiện tại đã được ký:

```bash
kubectl label namespace demo policy.sigstore.dev/include=true
```

Nếu label trước khi image được ký, Policy Controller có thể reject chính Rollout `api`.

## Take-Home: Payments Tenant

Bài tập lớn nằm ở:

```text
tenants/payments/
apps/payments/
evidence/payments/
```

Checklist evidence tổng cho lab sáng, lab chiều và challenge nằm ở:

```text
evidence/README.md
```

Guide giải thích toàn bộ YAML manifest và luồng chạy nằm ở:

```text
YAML-MANIFEST-GUIDE.md
```

ArgoCD apps:

```text
argocd/apps/payments.yaml
argocd/apps/payments-app.yaml
```

Nội dung:

- Namespace `payments` có label `policy.sigstore.dev/include=true`.
- RBAC `payments-dev` chỉ quản lý workload trong namespace `payments`.
- `ResourceQuota` + `LimitRange`.
- NetworkPolicy default-deny ingress và egress chỉ cho cùng namespace + DNS.
- App `payments-api` dùng image đã ký `w10-api:0.0.4` và pull bằng ESO-managed `ghcr-pull-secret`.

Trước khi sync, đảm bảo AWS Secrets Manager có secret:

```text
demo/ghcr/pull-secret
```

với JSON:

```json
{"username":"lken1514","password":"GITHUB_TOKEN_READ_PACKAGES"}
```

## Cleanup

```bash
# Delete ArgoCD applications
kubectl delete -f argocd/root.yaml

# Wait for resources to be cleaned up
kubectl get all -n demo
kubectl get all -n monitoring

# Delete ArgoCD
kubectl delete ns argocd

# Stop minikube
minikube stop -p w10
minikube delete -p w10
```
