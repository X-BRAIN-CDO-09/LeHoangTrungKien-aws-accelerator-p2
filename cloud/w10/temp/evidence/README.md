# W10 Evidence Checklist

File này gom evidence cho 3 phần của W10:

- Lab sáng: RBAC + Gatekeeper Admission.
- Lab chiều: ESO + Trivy + Cosign + Sigstore Policy Controller.
- Challenge: Payments tenant.

Mỗi mục nên có ảnh ArgoCD hoặc output terminal tương ứng. Nếu nộp bằng Markdown, paste output vào dưới từng mục.

## 0. Trạng thái GitOps chung

```bash
kubectl get applications -n argocd
kubectl get ns demo payments argocd gatekeeper-system external-secrets cosign-system
```

Kỳ vọng:

```text
root, app-api, security-rbac, gatekeeper, eso, policy-controller, supply-chain-policies, payments, payments-app đều Synced/Healthy.
Namespace demo và payments tồn tại.
```

Evidence cần lưu:

```text
[Ảnh ArgoCD Applications]
[Output kubectl get applications -n argocd]
```

## 1. Lab sáng - RBAC

```bash
kubectl auth can-i create deploy -n demo \
  --as alice

kubectl auth can-i create deploy -n kube-system \
  --as alice

kubectl auth can-i get pods -A \
  --as bob

kubectl auth can-i delete nodes \
  --as carol

kubectl auth can-i list pods -n demo \
  --as system:serviceaccount:demo:api
```

Kỳ vọng:

```text
alice create deploy -n demo        -> yes
alice create deploy -n kube-system -> no
bob get pods -A                    -> yes
carol delete nodes                 -> no
api list pods -n demo              -> yes
```

Evidence cần lưu:

```text
[Output 5 lệnh can-i]
```

## 2. Lab sáng - Gatekeeper Admission

Kiểm tra controller và constraints:

```bash
kubectl get pod -n gatekeeper-system
kubectl get constraints
kubectl get application security-gatekeeper-constraints -n argocd
```

Test manifest vi phạm:

```bash
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-deny-latest.yaml
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-deny-missing-limits.yaml
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-deny-root-user.yaml
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-deny-host-network.yaml
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-deny-missing-owner.yaml
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-deny-unapproved-registry.yaml
```

Test manifest hợp lệ:

```bash
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-allow-secure-pod.yaml
kubectl apply -f cloud/w10/temp/security-rbac-admission/gatekeeper/tests/test-allow-owner-workloads.yaml
kubectl get pod,deploy,rollout -n demo
```

Kỳ vọng:

```text
test-deny-* bị reject bởi Gatekeeper.
test-allow-* apply được.
Rollout api hiện tại không bị chính policy chặn.
```

Evidence cần lưu:

```text
[Ảnh/output reject từ Gatekeeper]
[Ảnh/output manifest hợp lệ pass]
```

## 3. Lab chiều - External Secrets Operator

Kiểm tra ESO và SecretStore:

```bash
kubectl get pod -n external-secrets
kubectl get secretstore aws-store -n demo
kubectl describe secretstore aws-store -n demo
kubectl get externalsecret db-creds -n demo
kubectl get secret db-secret -n demo
```

Kiểm tra secret được sync:

```bash
kubectl get secret db-secret -n demo -o jsonpath='{.data.password}' | base64 -d; echo
kubectl get pod -n demo -l app=secret-consumer
kubectl logs -n demo deploy/secret-consumer --tail=20
```

Kiểm tra GHCR pull secret:

```bash
kubectl get externalsecret ghcr-pull-secret -n demo
kubectl get secret ghcr-pull-secret -n demo
kubectl get sa api -n demo -o yaml | grep -A3 imagePullSecrets
```

Kỳ vọng:

```text
aws-store Ready=True.
db-creds Ready=True.
db-secret tồn tại và secret-consumer đọc được password.
ghcr-pull-secret tồn tại để pull private image từ GHCR.
```

Evidence cần lưu:

```text
[Output SecretStore/ExternalSecret Ready]
[Output db-secret và log secret-consumer]
```

## 4. Lab chiều - Trivy, Cosign, Sigstore

Kiểm tra image đã ký:

```bash
cosign verify \
  --key cloud/w10/temp/signing/cosign.pub \
  ghcr.io/x-brain-cdo-09/lehoangtrungkien-aws-accelerator-p2/w10-api:0.0.4
```

Kiểm tra policy controller:

```bash
kubectl get pod -n cosign-system
kubectl get endpoints webhook -n cosign-system
kubectl get clusterimagepolicy
kubectl describe clusterimagepolicy require-signed-w10-api
kubectl get ns demo payments --show-labels
```

Kiểm tra app pull image thành công:

```bash
kubectl get pod -n demo -l app=api
kubectl describe pod -n demo -l app=api | grep -E "Image:|Image ID:|Successfully pulled|Started" -A2
```

Kỳ vọng:

```text
cosign verify pass.
ClusterImagePolicy Ready=True.
Namespace demo/payments có label policy.sigstore.dev/include=true.
Pod api chạy image signed và Running.
```

Evidence cần lưu:

```text
[Ảnh GitHub Actions xanh: build, Trivy, sign]
[Output cosign verify]
[Output ClusterImagePolicy Ready]
```

## 5. Challenge - Payments Tenant RBAC

```bash
kubectl auth can-i create deploy -n payments \
  --as payments-dev

kubectl auth can-i create deploy -n demo \
  --as payments-dev

kubectl auth can-i get secrets -n payments \
  --as payments-dev

kubectl auth can-i update rolebindings -n payments \
  --as payments-dev
```

Kỳ vọng:

```text
create deploy -n payments       -> yes
create deploy -n demo           -> no
get secrets -n payments         -> no
update rolebindings -n payments -> no
```

Evidence cần lưu:

```text
[Output can-i của payments-dev]
```

## 6. Challenge - Quota và LimitRange

```bash
kubectl get resourcequota,limitrange -n payments
kubectl apply -f cloud/w10/temp/evidence/payments/quota-violation.yaml
kubectl apply -f cloud/w10/temp/evidence/payments/limitrange-default-demo.yaml
kubectl get pod payments-limits-defaulted -n payments -o yaml | grep -A12 resources
```

Kỳ vọng:

```text
quota-violation bị reject vì vượt ResourceQuota.
limitrange-default-demo được tạo và container được default resources.
```

Evidence cần lưu:

```text
[Output quota reject]
[Output pod đã được LimitRange default resources]
```

Cleanup sau khi lấy evidence:

```bash
kubectl delete pod payments-limits-defaulted -n payments --ignore-not-found
```

## 7. Challenge - NetworkPolicy chặn gọi chéo

```bash
kubectl get networkpolicy -n payments
kubectl apply -f cloud/w10/temp/apps/payments/tests/violating-cross-namespace-curl.yaml
kubectl logs -n payments payments-curl-demo-api
```

Kỳ vọng:

```text
Pod payments-curl-demo-api không gọi được service ở namespace demo.
NetworkPolicy cần CNI có enforce policy, ví dụ Calico.
```

Evidence cần lưu:

```text
[Output NetworkPolicy]
[Output curl/wget timeout hoặc failed]
```

Cleanup sau khi lấy evidence:

```bash
kubectl delete pod payments-curl-demo-api -n payments --ignore-not-found
```

## 8. Challenge - App hợp lệ chạy, vi phạm bị constraint cũ chặn

Kiểm tra app hợp lệ:

```bash
kubectl get application payments payments-app -n argocd
kubectl get pod -n payments -l app=payments-api
kubectl describe pod -n payments -l app=payments-api | grep -E "Image:|Image ID:|Started|Successfully pulled" -A2
```

Test vi phạm policy cũ:

```bash
kubectl apply -f cloud/w10/temp/apps/payments/tests/violating-missing-owner.yaml
```

Kỳ vọng:

```text
payments-api Running.
Manifest thiếu owner bị Gatekeeper reject.
Điểm quan trọng: constraint cũ đã áp cho namespace payments, không chỉ demo.
```

Evidence cần lưu:

```text
[Ảnh ArgoCD payments/payments-app Synced Healthy]
[Output payments-api Running]
[Output missing-owner bị reject]
```

## 9. Hai câu giải thích để nộp

```text
Payments được tách thành namespace riêng, RBAC chỉ cấp Role/RoleBinding trong namespace payments nên payments-dev không thể thao tác sang demo hoặc leo quyền bằng secrets/rolebindings. Guardrail cũ vẫn áp cho team mới vì Gatekeeper constraints đã mở rộng match namespace từ demo sang payments, còn Sigstore Policy Controller enforce theo label policy.sigstore.dev/include=true trên namespace payments.
```
