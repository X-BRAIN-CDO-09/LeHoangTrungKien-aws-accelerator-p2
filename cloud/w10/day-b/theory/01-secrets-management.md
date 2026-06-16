# Secrets Management

Secret không chỉ là "file nhạy cảm". Nó là dữ liệu có vòng đời: tạo, rotate, revoke, audit.

## Vấn đề của secret hard-code

- Lộ qua Git history.
- Khó rotate.
- Dùng chung sai giữa nhiều môi trường.
- Dev copy sai chỗ và leak ra log.

## Hướng dùng cho W10

- Secret nguồn gốc nằm ở AWS Secrets Manager.
- Kubernetes chỉ đóng vai trò điểm tiếp nhận.
- ESO đồng bộ về `Secret` trong namespace.
- App consume qua env vars hoặc mounted file.
