# Payments Evidence Checklist

## 1. RBAC cô lập

```bash
kubectl auth can-i create deploy -n payments --as payments-dev
kubectl auth can-i create deploy -n demo --as payments-dev
kubectl auth can-i get secrets -n payments --as payments-dev
kubectl auth can-i update rolebindings -n payments --as payments-dev
```

## 2. Quota và LimitRange

```bash
kubectl get resourcequota,limitrange -n payments
kubectl apply -f cloud/w10/temp/evidence/payments/quota-violation.yaml
kubectl apply -f cloud/w10/temp/evidence/payments/limitrange-default-demo.yaml
```

## 3. NetworkPolicy cô lập

```bash
kubectl get networkpolicy -n payments
kubectl apply -f cloud/w10/temp/apps/payments/tests/violating-cross-namespace-curl.yaml
kubectl logs -n payments payments-curl-demo-api
```

## 4. Guardrail cũ áp cho team mới

```bash
kubectl get pod -n payments -l app=payments-api
kubectl apply -f cloud/w10/temp/apps/payments/tests/violating-missing-owner.yaml
```

Kỳ vọng manifest thiếu `owner` bị Gatekeeper reject.
