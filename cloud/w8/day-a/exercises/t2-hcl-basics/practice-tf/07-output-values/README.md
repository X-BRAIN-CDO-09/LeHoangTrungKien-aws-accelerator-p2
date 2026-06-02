# 07 - Output Values

## Mục tiêu

Hiểu output dùng để expose giá trị sau khi Terraform tính toán.

## Đề bài

Trong `variables.tf`, khai báo vài biến bất kỳ liên quan đến project, environment, service.

Trong `locals.tf`, tạo ít nhất 3 local:

- Một string.
- Một list.
- Một map.

Trong `outputs.tf`, output cả 3 local đó.

## Yêu cầu

- Mỗi output có `description`.
- Một output đặt `sensitive = true` để hiểu cách Terraform che giá trị nhạy cảm.

