# W10 Reflection

## What I Learned

- RBAC chỉ giải quyết "ai được làm gì", admission policy giải quyết "resource tạo ra có được phép không".
- Secret cần có vòng đời và owner rõ ràng, không nên xuất hiện trong Git.
- Supply chain security có ý nghĩa khi image được scan, sign và verify ngay tại cluster.
- `ResourceQuota`, `LimitRange` và runbook là những guardrail vận hành rất thực tế.

## Key Concepts

- Role / RoleBinding:
- ClusterRole / ClusterRoleBinding:
- ServiceAccount:
- Gatekeeper:
- ConstraintTemplate:
- Constraint:
- ValidatingAdmissionPolicy:
- External Secrets Operator:
- Trivy:
- Cosign:
- Verify Images:
- ResourceQuota:
- LimitRange:
- Runbook:

## Lab Evidence

- `developer` can-i:
- `sre` can-i:
- `viewer` can-i:
- Gatekeeper denied workload:
- ESO rotated secret:
- Trivy failed on vulnerable artifact:
- Unsigned image rejected:
- Quota and LimitRange applied:

## Personal Notes

Ghi lại blocker, lệnh debug và những chính sách muốn giữ lại cho capstone.
