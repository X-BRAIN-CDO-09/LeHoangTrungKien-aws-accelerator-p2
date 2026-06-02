# 04 - ConfigMap And Secret Knowledge

## ConfigMap Là Gì?

ConfigMap lưu cấu hình không nhạy cảm, ví dụ:

- App mode.
- Feature flag.
- API base URL không bí mật.
- Config file.

## Secret Là Gì?

Secret lưu dữ liệu nhạy cảm hơn, ví dụ:

- Password.
- Token.
- API key.

Secret trong Kubernetes mặc định chỉ base64 encode, không phải tự động an toàn tuyệt đối. Production cần RBAC, encryption at rest và secret management tốt hơn.

## Cách Dùng

ConfigMap/Secret có thể được dùng dưới dạng:

- Environment variables.
- Mounted files.

## Khi Nào Dùng Gì?

- Dùng ConfigMap cho config không bí mật.
- Dùng Secret cho giá trị nhạy cảm.
- Không bake config/secret vào Docker image.

