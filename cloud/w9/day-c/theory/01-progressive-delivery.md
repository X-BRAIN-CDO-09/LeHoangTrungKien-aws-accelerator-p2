# 01 - Progressive Delivery

## Progressive Delivery là gì?

Progressive delivery là cách phát hành phần mềm theo từng bước nhỏ thay vì triển khai toàn bộ ngay lập tức. Mục tiêu là giảm rủi ro khi release và phát hiện lỗi sớm trước khi ảnh hưởng đến toàn bộ người dùng.

## Vì sao cần Progressive Delivery?

- Release an toàn hơn.
- Có thể đo chất lượng phiên bản mới bằng metrics thực tế.
- Giảm tác động nếu phiên bản mới bị lỗi.
- Dễ rollback hoặc abort khi phát hiện vấn đề.

## Các kỹ thuật phổ biến

- Canary deployment.
- Blue/Green deployment.
- Feature flag.
- A/B testing.

Trong W9, trọng tâm là canary deployment với Argo Rollouts.

