# Six Risk Checklist

## F-01 RBAC quá rộng

- Có `cluster-admin` cho user/team app không?
- Developer có đọc được `Secret` không?

## F-02 Pod security yếu

- Có `runAsNonRoot` không?
- Có `privileged: true` không?
- Có `readOnlyRootFilesystem` nếu phù hợp không?

## F-03 Supply chain yếu

- Image đã scan chưa?
- Image đã sign chưa?
- Admission có verify signature không?

## F-04 Secret không an toàn

- Secret có nằm trong Git/manifests không?
- Secret có đến từ AWS Secrets Manager qua ESO không?
- Rotation có vào pod đúng kỳ vọng không?

## F-05 Namespace không có governance

- Có `ResourceQuota` không?
- Có `LimitRange` không?

## F-06 Runbook / incident response thiếu

- Có runbook cho pod compromise không?
- Có runbook cho unsigned image reject không?
- Có owner và escalation path không?
