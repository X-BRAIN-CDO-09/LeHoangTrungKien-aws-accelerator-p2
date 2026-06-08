# Ngày A - GitOps và CI/CD

## Mục tiêu

- Hiểu các nguyên tắc cơ bản của GitOps và lý do Git được xem là nguồn sự thật của hệ thống.
- So sánh tổng quan giữa ArgoCD và Flux.
- Xây dựng luồng CI/CD với GitHub Actions:
  - Khi tạo pull request: chạy kiểm tra, validate và plan.
  - Khi merge vào main: apply thay đổi hoặc để ArgoCD tự đồng bộ desired state.
- Hiểu mô hình ArgoCD App of Apps, sync waves và các phương án rollback.

## Ghi chú

### GitOps

GitOps là phương pháp quản lý hạ tầng và ứng dụng bằng Git. Trạng thái mong muốn của hệ thống được lưu trong repository, sau đó một controller như ArgoCD sẽ theo dõi repository và liên tục đồng bộ cluster để khớp với trạng thái trong Git.

### ArgoCD vs Flux

ArgoCD thường dễ quan sát hơn vì có giao diện trực quan và luồng quản lý theo từng application. Flux nhẹ hơn, bám sát Kubernetes-native hơn và cũng được sử dụng phổ biến để tự động hóa GitOps.

### Rollback

- `git revert`: là cách rollback nên ưu tiên trong GitOps vì nó cập nhật lại desired state trong Git.
- `kubectl rollout undo`: hữu ích trong tình huống khẩn cấp, nhưng có thể gây drift nếu sau đó không cập nhật lại Git.

## Checklist thực hành

- [ ] Tạo GitHub Actions workflow để validate pull request.
- [ ] Tạo ArgoCD root application.
- [ ] Thêm các child application theo mô hình App of Apps.
- [ ] Thêm annotation sync-wave khi cần kiểm soát thứ tự đồng bộ.
- [ ] Ghi lại các lệnh rollback và quy tắc lựa chọn cách rollback.

## Nội dung theory

- `01-github-actions-terraform.md`: CI/CD với GitHub Actions cho Terraform, Plan on PR và Apply on Merge.
- `02-gitops-tooling-comparison.md`: GitOps, pull model, drift reconciliation và lựa chọn công cụ triển khai.
- `03-argocd-app-management.md`: Quản lý nhiều application với ArgoCD, sync waves, prune và self-heal.
- `04-rollback-strategies.md`: So sánh rollback bằng `git revert`, `kubectl rollout undo` và ArgoCD UI.

## Cấu trúc thư mục

```text
day-a/
  theory/      # Ghi chú lý thuyết GitOps, CI/CD, ArgoCD, rollback
  exercises/   # Bài thực hành GitHub Actions và ArgoCD
```
