# Runbook - Rotate DB Secret Với ESO

1. Đổi value của secret `demo/db/password` trong AWS Secrets Manager.
2. Đợi tối đa 30 giây theo `refreshInterval`.
3. Kiểm tra Kubernetes Secret:

```bash
kubectl get secret db-secret -n demo -o jsonpath='{.data.password}' | base64 -d
```

4. Kiểm tra Pod không restart:

```bash
kubectl get pod -n demo -l app=secret-consumer
kubectl logs -n demo deploy/secret-consumer --tail=20
```

Kỳ vọng: Secret đổi dưới 60 giây, `AGE` của Pod không đổi.
