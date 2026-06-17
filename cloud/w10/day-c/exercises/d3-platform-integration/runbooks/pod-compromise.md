# Runbook - Nghi ngờ Pod bị compromise

## Trigger

- Alert bất thường từ Falco / audit / canary / ứng dụng.
- Pod tạo network traffic lạ.
- Image hoặc process không nằm trong baseline.

## 5 phút đầu

1. Xác nhận namespace, pod, node, image digest.
2. Scale traffic về stable version nếu pod nằm trong rollout.
3. Cô lập pod hoặc node tùy mức độ ảnh hưởng.
4. Giữ evidence: events, logs, describe, image digest, timeline.

## Lệnh nhanh

```bash
kubectl get pod <pod> -n <ns> -o wide
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp
```

## Containment

- Nếu chỉ 1 pod lỗi: xóa pod, scale deployment, revoke secret liên quan.
- Nếu nghi node compromise: cordon + drain node, snapshot / evidence theo AWS runbook.
- Nếu nghi secret leak: rotate secret tại nguồn, xác nhận ESO đồng bộ lại.
