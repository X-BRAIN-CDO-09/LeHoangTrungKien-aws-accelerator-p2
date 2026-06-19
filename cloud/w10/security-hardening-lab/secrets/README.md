# Lab Secrets

Folder này chứa cấu hình External Secrets Operator cho namespace `flipkart`.

## Secret nguồn trong AWS

Tạo secret trong AWS Secrets Manager:

```text
/w10/flipkart/backend
```

Giá trị dạng JSON:

```json
{
  "DB_PASSWORD": "initial-password",
  "API_KEY": "initial-api-key"
}
```

## Apply

```bash
kubectl apply -f cloud/w10/security-hardening-lab/secrets/eso/30-cluster-secret-store-aws.yaml
kubectl apply -f cloud/w10/security-hardening-lab/secrets/eso/31-external-secret-flipkart-backend.yaml
kubectl apply -f cloud/w10/security-hardening-lab/secrets/eso/32-demo-secret-consumer.yaml
```

## Kiểm tra

```bash
kubectl get externalsecret -n flipkart
kubectl get secret flipkart-backend-secrets -n flipkart
kubectl logs deployment/secret-consumer -n flipkart -f
```
