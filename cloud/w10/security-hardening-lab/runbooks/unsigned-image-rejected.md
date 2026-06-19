# Runbook - Unsigned Image bị reject

## Trigger

Deploy bị reject với thông điệp verify image signature thất bại.

## Kiểm tra nhanh

1. Image có đúng digest/tag vừa build không.
2. Pipeline đã `cosign sign` chưa.
3. Public key / identity verify có khớp policy không.
4. Có đang deploy image từ registry khác phạm vi policy không.

## Lệnh nhanh

```bash
kubectl describe deploy <name> -n <ns>
kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp
cosign verify --key cosign.pub <registry>/<image>:<tag>
```

## Cách xử lý

- Ký lại image nếu pipeline bỏ sót bước sign.
- Nếu key thay đổi, cập nhật policy có review.
- Chỉ dùng exception tạm thời nếu có phê duyệt và expiry rõ ràng.
