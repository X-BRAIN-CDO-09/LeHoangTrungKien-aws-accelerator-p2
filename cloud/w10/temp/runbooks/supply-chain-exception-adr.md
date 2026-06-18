# ADR - Temporary CVE Exception

## Context

Trivy fail vì image có CVE HIGH/CRITICAL nhưng vendor chưa có bản vá.

## Decision

Exception chỉ được dùng khi:

- CVE không có bản vá khả dụng.
- Có mitigation tạm thời.
- Có ngày hết hạn rõ ràng.

## Expiry

Exception hết hạn sau tối đa 14 ngày hoặc ngay khi vendor phát hành bản vá.

## Follow-up

- Theo dõi advisory của vendor.
- Tạo issue cập nhật image.
- Xóa exception khi image mới đã pass Trivy.
