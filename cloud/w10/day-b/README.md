# Ngày B - Secrets Rotation và Supply Chain Security

## Mục tiêu

- Hiểu tại sao không commit secret vào Git.
- Dùng AWS Secrets Manager + External Secrets Operator để cấp phát secret vào cluster.
- Thử refresh interval ngắn để quan sát secret rotate mà không cần rollout app.
- Thêm image scanning bằng Trivy trong CI.
- Hiểu Cosign ký image và admission verify signature.

## Checklist thực hành

- [ ] Tạo `ClusterSecretStore`.
- [ ] Tạo `ExternalSecret` map từ AWS Secrets Manager vào namespace app.
- [ ] Kiểm tra secret được cập nhật theo `refreshInterval`.
- [ ] Thêm workflow Trivy fail khi có HIGH/CRITICAL.
- [ ] Ghi chú cách ký image bằng Cosign.
- [ ] Chuẩn bị policy verify image signature.

## Nội dung theory

- `01-secrets-management.md`
- `02-external-secrets-operator.md`
- `03-trivy-and-image-scanning.md`
- `04-cosign-and-signature-verification.md`
