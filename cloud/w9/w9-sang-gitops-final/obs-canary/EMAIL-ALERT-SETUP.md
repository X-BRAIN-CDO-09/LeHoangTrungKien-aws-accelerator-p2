# Thiết lập Email Alert cho Alertmanager

Alertmanager gửi các cảnh báo `warning` và `critical` tới Gmail đã cấu hình trong
`argocd/apps/kube-prometheus-stack.yaml`.

Mật khẩu SMTP không được lưu trong Git. Secret `flipkart-alertmanager-smtp`
phải được tạo trực tiếp trong cluster.

## 1. Chuẩn bị Gmail App Password

1. Bật xác minh hai bước cho tài khoản Google.
2. Mở trang quản lý Google App Passwords.
3. Tạo App Password dành cho Alertmanager.
4. Giữ App Password để nhập vào terminal ở bước tiếp theo.

Không sử dụng mật khẩu đăng nhập Gmail thông thường.

## 2. Tạo SMTP Secret ngoài Git

Chạy trong terminal WSL:

```bash
read -s -p "Gmail App Password: " SMTP_PASSWORD
echo

kubectl create secret generic flipkart-alertmanager-smtp \
  --namespace monitoring \
  --from-literal=smtp-password="${SMTP_PASSWORD}" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

unset SMTP_PASSWORD
```

Kiểm tra Secret tồn tại mà không hiển thị giá trị:

```bash
kubectl get secret flipkart-alertmanager-smtp -n monitoring
```

## 3. Đồng bộ cấu hình Alertmanager

Commit và push file Application sau khi cấu hình email được cập nhật:

```bash
git add \
  .gitignore \
  cloud/w9/w9-sang-gitops-final/argocd/apps/kube-prometheus-stack.yaml \
  cloud/w9/w9-sang-gitops-final/obs-canary/EMAIL-ALERT-SETUP.md

git commit -m "[W9-D2] configure Alertmanager email notifications"
git push
```

Chờ ArgoCD đồng bộ:

```bash
kubectl get application kube-prometheus-stack -n argocd -w
kubectl get pods -n monitoring
```

## 4. Xác nhận cấu hình và gửi email thử

Kiểm tra Alertmanager đã mount Secret và không có lỗi SMTP:

```bash
kubectl get alertmanager kube-prometheus-stack-alertmanager \
  -n monitoring \
  -o jsonpath='{.spec.secrets}'

kubectl logs -n monitoring \
  statefulset/alertmanager-kube-prometheus-stack-alertmanager \
  -c alertmanager \
  --tail=100
```

Để tạo alert thật, triển khai một backend canary có `ERROR_RATE=0.5` và giữ load
test chạy. Khi `FlipkartBackendFastBurn` chuyển sang `Firing`, Alertmanager sẽ
gửi email sau khoảng `group_wait: 10s`.

Theo dõi alert:

```bash
kubectl port-forward -n monitoring \
  svc/kube-prometheus-stack-alertmanager 9093:9093
```

Mở `http://127.0.0.1:9093` và kiểm tra email đến. Nếu không nhận được email,
kiểm tra cả thư mục Spam và log Alertmanager.

## 5. Bằng chứng

Chụp email nhận được và lưu thành:

```text
obs-canary/evidence/05-alert-email.png
```

Che App Password và thông tin nhạy cảm trước khi lưu evidence.
