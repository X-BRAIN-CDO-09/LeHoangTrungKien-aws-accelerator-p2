# Evidence - K8s on AWS Terraform 1-Click

## Nộp Gì

Deliverables:

- Repo Terraform đầy đủ trong folder `lab`.
- `README.md` có:
  - lệnh chạy,
  - sơ đồ kiến trúc,
  - giải thích cách wire providers,
  - cách verify,
  - cách destroy.
- Bằng chứng app chạy qua ALB:
  - URL ALB mở được trên browser,
  - ảnh chụp màn hình hoặc clip ngắn.
- Bằng chứng destroy sạch sau khi test.

## Lệnh Chạy

Chạy từ folder `lab`:

```bash
terraform init && terraform apply -auto-approve
```

Lấy URL ALB:

```bash
terraform output alb_url
```

Destroy:

```bash
terraform destroy -auto-approve
```

## Bằng Chứng Cần Chụp

### 1. Terraform Apply Thành Công

Chụp terminal có output `Apply complete` và các outputs:

```text
alb_url = "http://..."
app_image = "....dkr.ecr.ap-southeast-1.amazonaws.com/demo-app-...:v1"
ec2_public_ip = "..."
node_port = 30080
```

Ảnh/clip:

![Terraform apply output](evidence/terraform-apply-alb-output.png)

### 2. URL ALB Mở Được App

URL:

```text
http://k8s-alb-lab-e3053917-alb-1752452592.ap-southeast-1.elb.amazonaws.com
```

Bằng chứng browser:

![Browser opens ALB demo app](evidence/browser-alb-demo-app.png)

### 3. App Thực Sự Chạy Trong Kubernetes

SSH vào EC2 nếu cần debug:

```bash
ssh -i .generated/<key-name>.pem ubuntu@<ec2_public_ip>
```

Kiểm tra cluster:

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get deploy
```

Output mong muốn:

```text
deployment/demo-app   READY
pod/demo-app-...      Running
service/demo-app      NodePort      80:30080/TCP
```

Bằng chứng:

```text
TODO: thêm ảnh hoặc output kubectl chứng minh app chạy trong K8s
```

### 4. ALB Forward Vào NodePort

Port matching:

```text
ALB :80 -> EC2 :30080 -> kind hostPort :30080 -> Service nodePort :30080 -> Pod :80
```

Các nơi dùng chung biến `app_node_port = 30080`:

- Target Group port.
- EC2 Security Group ingress.
- `kind extraPortMappings`.
- Kubernetes Service `nodePort`.

Bằng chứng:

```text
TODO: thêm ảnh Target Group healthy hoặc output AWS CLI nếu cần
```

### 5. Destroy Sạch

Chạy:

```bash
terraform destroy -auto-approve
```

Chụp terminal có:

```text
Destroy complete
```

Kiểm tra không còn resource lab:

```bash
aws ec2 describe-vpcs \
  --region ap-southeast-1 \
  --filters Name=tag:Name,Values="k8s-alb-lab-*"

aws elbv2 describe-load-balancers \
  --region ap-southeast-1

aws ecr describe-repositories \
  --region ap-southeast-1
```

Bằng chứng:

![Terraform destroy complete](evidence/terraform-destroy-complete.png)

## Provider Wire

Providers được dùng trong cùng cấu hình Terraform:

- `hashicorp/aws`
- `hashicorp/tls`
- `hashicorp/local`
- `hashicorp/cloudinit`

Wire:

```text
tls_private_key.ec2
-> aws_key_pair.generated
-> aws_instance key_name
```

```text
tls_private_key.ec2
-> local_sensitive_file.generated_private_key
-> .generated/<name>.pem
```

```text
user_data.sh.tftpl
-> data.cloudinit_config.bootstrap
-> aws_instance.user_data
```

```text
aws_ecr_repository
-> local Docker build/push
-> EC2 user_data creates imagePullSecret
-> Kubernetes Deployment pulls image from ECR
```

## Acceptance Checklist

- [ ] `1` lệnh từ repo sạch dựng được toàn bộ:

```bash
terraform init && terraform apply -auto-approve
```

- [ ] `terraform output alb_url` trả về URL ALB.
- [ ] Browser mở URL ALB thấy trang demo app.
- [ ] App chạy trong Kubernetes Pod, không chạy trực tiếp trên EC2.
- [ ] Service là `NodePort` và dùng port cố định `30080`.
- [ ] ALB target group forward vào EC2 port `30080`.
- [ ] Có ít nhất `2` providers được wire trong cùng cấu hình.
- [ ] Giải thích được vì sao chọn `kind + NodePort + ALB + ECR`.
- [ ] `terraform destroy -auto-approve` dọn sạch sau khi test.
- [ ] Có thể dựng lại từ đầu cho kết quả tương đương.

## Vì Sao Thiết Kế Này Đạt

- `kind` chạy Kubernetes single-node trên EC2, phù hợp yêu cầu `1 EC2`.
- App được deploy bằng `kubectl apply` trong `user_data`, chạy trong Kubernetes Pod.
- Image được build local, push lên ECR, sau đó Pod pull image từ ECR.
- `NodePort` cố định giúp Terraform và ALB không cần đọc dynamic Service port từ Kubernetes.
- ALB public expose app ra Internet qua HTTP port `80`.
- Providers phụ trợ `tls`, `local`, `cloudinit` có vai trò rõ ràng, không thêm chỉ để đủ số lượng.
- Destroy có thể dọn sạch toàn bộ resource do Terraform quản lý.
