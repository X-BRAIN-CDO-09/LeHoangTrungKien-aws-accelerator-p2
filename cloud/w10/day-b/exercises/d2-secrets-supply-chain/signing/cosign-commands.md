# Cosign Commands

## Ký theo chế độ keyless

```bash
cosign sign --yes <registry>/<image>:<tag>
cosign verify <registry>/<image>:<tag>
```

## Ký theo chế độ dùng key

```bash
cosign generate-key-pair
cosign sign --key cosign.key <registry>/<image>:<tag>
cosign verify --key cosign.pub <registry>/<image>:<tag>
```

## Ghi chú thực chiến

- Build image xong mới ký.
- Verify ở admission để block image unsigned.
- Nếu cần exception, ghi ADR có expiry date.
