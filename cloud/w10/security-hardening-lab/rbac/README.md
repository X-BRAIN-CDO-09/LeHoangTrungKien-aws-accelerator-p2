# Lab RBAC

Folder này chứa RBAC dùng trực tiếp cho lab T5-T6 trên namespace `flipkart`.

## Apply

```bash
kubectl apply -f cloud/w10/security-hardening-lab/base/00-namespaces.yaml
kubectl apply -f cloud/w10/security-hardening-lab/rbac/10-serviceaccounts.yaml
kubectl apply -f cloud/w10/security-hardening-lab/rbac/11-roles.yaml
kubectl apply -f cloud/w10/security-hardening-lab/rbac/12-rolebindings.yaml
```

## Kiểm tra nhanh

```bash
kubectl auth can-i get pods --as system:serviceaccount:flipkart:viewer -n flipkart
kubectl auth can-i get secrets --as system:serviceaccount:flipkart:developer -n flipkart
kubectl auth can-i patch rollout --as system:serviceaccount:flipkart:sre -n flipkart
```
