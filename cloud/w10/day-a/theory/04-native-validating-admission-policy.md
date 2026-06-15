# Native ValidatingAdmissionPolicy

Kubernetes 1.30+ có `ValidatingAdmissionPolicy` native dùng CEL. Đây là lựa chọn nhẹ hơn Gatekeeper nếu policy đơn giản.

## Khi nên dùng

- Chỉ cần policy đơn giản, ít phụ thuộc.
- Muốn giảm số controller phải cài thêm.
- Muốn policy native của Kubernetes.

## Khi vẫn nên dùng Gatekeeper

- Cần tái sử dụng template policy.
- Cần thư viện policy có sẵn.
- Cần audit report để đọc.
- Cần logic policy phức tạp hơn CEL.

## Quy tắc thực chiến

- Policy đơn giản, cluster mới: có thể bắt đầu bằng native.
- Policy team-scale, cần governance và template: Gatekeeper phù hợp hơn.
