# Trivy và Image Scanning

Trivy scan image để tìm CVE, package vulnerable và misconfiguration.

## Policy gợi ý cho W10

- PR scan image hoặc filesystem.
- Fail nếu có `HIGH` hoặc `CRITICAL`.
- Có exception có thời hạn, không exception vô thời hạn.

## Cách đọc kết quả

- Vulnerability ID
- Severity
- Package bị ảnh hưởng
- Fixed version

W10 không cần perfection. Mục tiêu là có chốt chặn rõ ràng trong CI.
