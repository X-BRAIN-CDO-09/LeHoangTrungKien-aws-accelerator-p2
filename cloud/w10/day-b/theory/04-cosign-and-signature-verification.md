# Cosign và Verify Signature

Ký image giải quyết câu hỏi: image này có đúng được build bởi pipeline hợp lệ không?

## Hai chế độ phổ biến

- Keyless OIDC: phù hợp với CI hiện đại, ít phải quản lý key tay.
- Key-based signing: dễ học luồng ký và verify rõ hơn.

## Vị trí đặt control

- CI: ký image sau build.
- Registry: scan image và lưu artifact.
- Admission: verify chữ ký trước khi cho deploy.

Kiểm tra ở admission layer là quan trọng vì đây là điểm "không tin developer hứa".
