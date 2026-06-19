# Lab 2.1 - External Secrets Operator

Mục tiêu: Secret thật nằm ở AWS Secrets Manager, Kubernetes chỉ nhận bản sync qua ESO. Repo không commit access key hoặc password.

## Chuẩn bị secret AWS credential cho minikube

```bash
kubectl create secret generic aws-creds -n demo \
  --from-literal=access-key="$AWS_ACCESS_KEY_ID" \
  --from-literal=secret-key="$AWS_SECRET_ACCESS_KEY"
```

SecretStore trong `secret-store.yaml` đọc credential từ Secret này. Trên EKS thật, dùng mẫu `secret-store-irsa.example.yaml` để chuyển sang IRSA thay vì access key.

## Secret nguồn trên AWS

ExternalSecret đang đọc remote key:

```text
demo/db/password
```

và tạo Kubernetes Secret:

```text
demo/db-secret
```

`refreshInterval: 30s` để đạt yêu cầu rotate dưới 60 giây.

## GHCR pull secret

Vì image `w10-api` nằm trong GHCR private package, namespace `demo` cần Docker registry secret. Tạo AWS Secrets Manager secret dạng JSON:

```bash
aws secretsmanager create-secret \
  --name demo/ghcr/pull-secret \
  --secret-string '{"username":"<github-username>","password":"<github-token-read-packages>"}' \
  --region ap-southeast-1
```

Nếu secret đã tồn tại:

```bash
aws secretsmanager put-secret-value \
  --secret-id demo/ghcr/pull-secret \
  --secret-string '{"username":"<github-username>","password":"<github-token-read-packages>"}' \
  --region ap-southeast-1
```

`ghcr-pull-secret.yaml` sẽ sync secret này thành Kubernetes Secret:

```text
demo/ghcr-pull-secret
```

ServiceAccount `api` dùng secret đó qua `imagePullSecrets`, nên Pod có thể pull image private từ GHCR.

`ClusterSecretStore` trong `cluster-secret-store.yaml` dùng cùng AWS credential ở namespace `demo` để các tenant khác, ví dụ `payments`, có thể sync secret GHCR riêng trong namespace của họ mà không commit token.

## Nghiệm thu

```bash
kubectl get externalsecret -n demo
kubectl get secret db-secret -n demo -o jsonpath='{.data.password}' | base64 -d
kubectl get secret ghcr-pull-secret -n demo
kubectl get pod -n demo -l app=secret-consumer
kubectl logs -n demo deploy/secret-consumer --tail=20
```

Sau khi đổi value trên AWS Secrets Manager, Secret trong Kubernetes phải đổi trong vòng dưới 60 giây. Pod `secret-consumer` không restart vì đọc secret qua volume.
