# Ngày C - Platform Integration, Runbook và Cost Guard

## Mục tiêu

- Kết nối guardrails W8 -> W10 thành mini platform.
- Thêm `ResourceQuota` và `LimitRange`.
- Chuẩn bị skeleton cho bootstrap GitOps security layer.
- Tạo runbook sự cố cơ bản cho pod compromise và unsigned image.
- Ghi lại cost guard tối thiểu để tránh "lab nổ tiền" vô tình.

## Checklist thực hành

- [ ] Apply quota và limit cho namespace team.
- [ ] Tạo namespace platform-security.
- [ ] Gom security app vào bootstrap structure.
- [ ] Chạy chaos test đơn giản và ghi expected signals.
- [ ] Điền runbook.
- [ ] Bật AWS Cost Anomaly Detection và gắn owner.

## Nội dung theory

- `01-platform-integration.md`
- `02-resource-governance.md`
- `03-runbook-thinking.md`
- `04-cost-guardrails.md`
