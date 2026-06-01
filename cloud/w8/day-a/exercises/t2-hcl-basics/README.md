# Bài Tập T2 - HCL Cơ Bản

Bài tập này dùng để luyện cú pháp Terraform mà không tạo tài nguyên cloud thật.

## Các File

- `versions.tf`: yêu cầu Terraform phiên bản `>= 1.6.0`.
- `variables.tf`: khai báo input, type, và default.
- `locals.tf`: tính toán giá trị dẫn xuất từ variables.
- `outputs.tf`: xuất các giá trị đã tính.

## Cần Đọc Từng Dòng Như Thế Nào

Bắt đầu với `variables.tf`:

- Biến nào là string?
- Biến nào là list?
- Biến nào là map?
- Biến nào có `default`?
- Vì sao biến đó có thể có `default`?

Sau đó đọc `locals.tf`:

- `name_prefix` được tạo như thế nào?
- `for` expression tạo `service_names` như thế nào?
- `merge` gộp default tags với metadata tính toán như thế nào?

Cuối cùng đọc `outputs.tf`:

- Những local value nào được xuất ra?
- Output sẽ trông như thế nào nếu dùng giá trị default?

## Lệnh Chạy

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan
```

## Evidence Cần Ghi Lại

Ghi vào `cloud/w8/reflection.md`:

- Các lệnh đã chạy.
- Output mình dự đoán trước khi chạy `plan`.
- Output thực tế sau khi chạy `plan`.
- Một câu hỏi còn thắc mắc về HCL.
