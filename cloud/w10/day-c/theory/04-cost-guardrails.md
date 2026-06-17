# Cost Guardrails

Lab cloud hay bị "trời ơi sao bill lên" vì để tài nguyên chạy qua đêm.

## Guardrail tối thiểu

- Tag owner + expiry cho tài nguyên.
- Cost Anomaly Detection.
- Budget threshold + email.
- Checklist destroy cuối ngày nếu là lab tạm.

## K8s cũng liên quan cost

- Request/limit quá cao làm node phình.
- Prometheus retention quá dài.
- Log volume cao.
- Canary để quá nhiều replica lâu hơn cần thiết.
