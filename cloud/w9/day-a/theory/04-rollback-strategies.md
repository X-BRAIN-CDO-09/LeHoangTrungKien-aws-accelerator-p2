# 04 - Chiến lược Rollback: git revert và kubectl rollout undo

Rollback không chỉ là "quay về bản cũ". Trong GitOps, rollback còn phải trả lời thêm một câu hỏi: sau khi xử lý sự cố, Git và cluster có còn khớp nhau không?

Nếu chỉ sửa trực tiếp trong cluster, ứng dụng có thể chạy lại nhanh nhưng Git vẫn đang chứa cấu hình lỗi. Nếu chỉ sửa bằng Git, quy trình sạch hơn nhưng có thể chậm trong lúc incident đang diễn ra.

## Cách 1: Rollback bằng git revert

Đây là hướng phù hợp nhất với GitOps vì thay đổi bắt đầu từ source of truth.

```bash
git revert <bad-commit-sha>
git push
```

Sau khi commit revert được push lên, ArgoCD sẽ thấy desired state đã quay về phiên bản ổn định và sync cluster theo Git.

Điểm mạnh:

- Git history thể hiện rõ việc rollback.
- Cluster không bị lệch khỏi repository.
- Phù hợp với quy trình review, audit và làm việc nhóm.
- Giảm nguy cơ version lỗi bị ArgoCD sync trở lại.

Điểm yếu:

- Không nhanh bằng thao tác trực tiếp trên cluster.
- Nếu quy trình yêu cầu PR approval, thời gian khôi phục có thể lâu hơn.

## Cách 2: Rollback trực tiếp bằng kubectl

Khi sự cố đang ảnh hưởng người dùng rõ ràng, có thể cần rollback ngay ở Kubernetes:

```bash
kubectl rollout undo deployment/demo-app -n demo
kubectl rollout status deployment/demo-app -n demo --timeout=180s
```

Cách này tác động vào actual state. Kubernetes sẽ đưa Deployment về revision trước đó nếu còn lịch sử rollout.

Điểm mạnh:

- Phản ứng nhanh trong tình huống khẩn cấp.
- Không cần chờ pipeline hoàn tất.
- Hữu ích khi ưu tiên trước mắt là giảm ảnh hưởng đến user.

Điểm yếu:

- Git không tự thay đổi theo.
- ArgoCD có thể báo `OutOfSync`.
- Nếu auto-sync vẫn bật và Git chưa sửa, bản lỗi có thể bị apply lại.

## Cách 3: Rollback từ ArgoCD UI

ArgoCD UI có phần history để chọn revision cũ. Cách này dễ quan sát hơn `kubectl` vì có thể nhìn được app, revision và trạng thái sync.

Tuy nhiên, đây vẫn là thao tác chữa cháy nếu Git chưa được sửa. Sau khi rollback bằng UI, cần nhanh chóng revert hoặc chỉnh manifest trong Git.

## Bảng quyết định nhanh

| Tình huống | Cách nên dùng |
| --- | --- |
| Lỗi nhỏ, chưa ảnh hưởng nhiều | `git revert` |
| Lỗi production nghiêm trọng | `kubectl rollout undo` hoặc ArgoCD UI trước |
| Sau khi chữa cháy xong | Revert hoặc sửa lại Git ngay |
| Muốn giữ audit trail sạch | Ưu tiên rollback bằng Git |

## Quy tắc rút ra

Rollback nhanh là cần thiết, nhưng không được để cluster và Git lệch nhau lâu. Cách làm tốt là xử lý incident trước nếu cần, sau đó đưa trạng thái mong muốn quay lại Git để ArgoCD tiếp tục quản lý hệ thống đúng chuẩn GitOps.
