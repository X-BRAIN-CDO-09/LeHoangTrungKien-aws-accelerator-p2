# 05 - NetworkPolicy Knowledge

## NetworkPolicy Là Gì?

NetworkPolicy kiểm soát traffic vào/ra Pod dựa trên label selector.

Mặc định, nếu cluster không có NetworkPolicy hoặc CNI không enforce policy, Pod có thể nói chuyện với nhau khá tự do.

## Ingress Và Egress

- Ingress: traffic đi vào Pod.
- Egress: traffic đi ra khỏi Pod.

## Selector

NetworkPolicy chọn Pod bằng `podSelector`.

Ví dụ policy áp dụng cho Pod có label:

```yaml
app: backend
```

Sau đó policy có thể cho phép ingress từ Pod có label:

```yaml
app: frontend
```

## Lưu Ý Với minikube

NetworkPolicy cần CNI hỗ trợ policy. Nếu minikube dùng CNI không enforce NetworkPolicy, manifest vẫn apply được nhưng policy có thể không có hiệu lực thực tế.

