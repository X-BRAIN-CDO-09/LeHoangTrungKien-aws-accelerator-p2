# 01 - GitHub Actions và Terraform

## Vấn đề cần giải quyết

Khi dùng Terraform, mỗi thay đổi trong code đều có thể tạo ảnh hưởng trực tiếp đến hạ tầng thật. Nếu một người chạy `terraform apply` từ máy cá nhân mà chưa được review, team rất khó biết thay đổi đó đã được kiểm tra chưa, có xóa nhầm tài nguyên không, hoặc ai là người thực hiện.

Vì vậy, Terraform nên được đưa vào pipeline CI/CD. GitHub Actions sẽ đóng vai trò như một "người gác cổng", giúp kiểm tra thay đổi trước khi merge và chỉ triển khai khi thay đổi đã đi qua quy trình chung.

## Luồng đề xuất

Luồng cơ bản cần nắm là:

```text
Create branch -> Edit Terraform -> Pull Request -> Plan -> Review -> Merge -> Apply
```

Điểm quan trọng là `plan` xảy ra trước khi merge, còn `apply` chỉ xảy ra sau khi thay đổi đã được chấp nhận.

## Khi mở Pull Request

- `terraform fmt -check` để kiểm tra format.
- `terraform init` để chuẩn bị provider và backend.
- `terraform validate` để phát hiện lỗi cấu hình cơ bản.
- `terraform plan` để xem trước diff của hạ tầng.

Kết quả `terraform plan` giống như bản nháp của thay đổi hạ tầng. Reviewer không chỉ đọc code, mà còn thấy Terraform dự định thêm, sửa hoặc xóa tài nguyên nào.

Ví dụ, nếu PR chỉ định sửa tag nhưng plan lại báo destroy một EC2 instance, đây là tín hiệu nguy hiểm cần dừng lại để kiểm tra.

## Khi merge vào main

Sau khi PR được approve và merge, pipeline có thể chạy apply:

```bash
terraform apply -auto-approve
```

Ở bước này, thay đổi đã được xem xét nên việc apply tự động sẽ an toàn hơn so với việc từng người tự apply trên máy cá nhân.

Tuy nhiên, nếu phần thay đổi là Kubernetes manifest theo mô hình GitOps, GitHub Actions có thể chỉ cần validate. Việc sync vào cluster nên để ArgoCD xử lý, vì ArgoCD mới là controller chịu trách nhiệm giữ cluster khớp với Git.

## Giá trị mang lại

- Reviewer có thêm dữ liệu để quyết định có nên merge hay không.
- Hạn chế thay đổi hạ tầng không qua kiểm soát.
- Log của GitHub Actions giúp truy vết lại từng lần plan/apply.
- Môi trường chạy Terraform thống nhất hơn so với máy local của từng thành viên.

## Điểm cần cẩn thận

- Không lưu access key, token hoặc password trong repo.
- Nên dùng GitHub Secrets hoặc OIDC để cấp quyền cho workflow.
- Nhánh `main` nên có branch protection.
- Với production, không nên apply ngay lập tức nếu chưa có bước phê duyệt.
- State backend cần được cấu hình ổn định trước khi chạy CI/CD.

## Kết luận

GitHub Actions không chỉ dùng để build app, mà còn có thể giúp quản lý hạ tầng an toàn hơn. `Plan on PR` giúp nhìn trước tác động, còn `Apply on Merge` đảm bảo chỉ thay đổi đã được review mới được triển khai.
