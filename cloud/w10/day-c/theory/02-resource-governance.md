# Resource Governance

`ResourceQuota` và `LimitRange` không hào nhoáng, nhưng chúng ngăn một namespace ăn hết tài nguyên cluster.

## ResourceQuota

Giới hạn tổng tài nguyên namespace có thể dùng.

## LimitRange

Đặt default request/limit và max/min cho từng container.

## Tình huống thường gặp

- Team có quyền deploy nhưng quên requests/limits.
- Một app scale lỗi, ăn hết CPU/RAM.
- Namespace test tạo quá nhiều pod.

Hai resource này là phần "operate" rất đời thường nhưng cần thiết.
