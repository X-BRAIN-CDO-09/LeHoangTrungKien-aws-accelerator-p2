# Flipkart MERN GitOps Notes

## Source Code
Upstream repository:

```text
https://github.com/jigar-sable/flipkart-mern.git
```

Ứng dụng:

- Chạy bằng `node server.js`.
- Lắng nghe port `4000`.
- Khi `NODE_ENV=production`, Express phục vụ React build từ `frontend/build`.
- Cần MongoDB và nhiều biến môi trường nhạy cảm.

## Vì sao ArgoCD không trỏ trực tiếp vào source repository?

ArgoCD triển khai Kubernetes manifests, Helm chart hoặc Kustomize. ArgoCD không tự:

- Chạy `npm install`.
- Build React frontend.
- Build Docker image.
- Tạo MongoDB credentials.

Do repo `flipkart-mern` chưa có Dockerfile và Kubernetes manifests, child Application trỏ vào thư mục manifest trong repository GitOps hiện tại:

```text
cloud/w9/w9-sang-gitops-final/flipkart/k8s
```

## Các bước còn cần làm

### 1. Build hai Docker image

Chạy từ thư mục gốc repository:

```bash
docker build \
  -f cloud/w9/w9-sang-gitops-final/app/Dockerfile.backend \
  -t docker.io/kienlht/flipkart-backend:latest \
  cloud/w9/w9-sang-gitops-final/app

docker build \
  -f cloud/w9/w9-sang-gitops-final/app/Dockerfile.frontend \
  -t docker.io/kienlht/flipkart-frontend:latest \
  cloud/w9/w9-sang-gitops-final/app
```

### 2. Nạp image vào Minikube

Lab local không bắt buộc push image lên Docker Hub:

```bash
minikube image load docker.io/kienlht/flipkart-backend:latest
minikube image load docker.io/kienlht/flipkart-frontend:latest
minikube image ls | grep flipkart
```

Manifest dùng `imagePullPolicy: IfNotPresent`, vì vậy Kubernetes ưu tiên image đã
được nạp vào Minikube.

### 3. Database cho lab

Child Application backend triển khai MongoDB nội bộ với:

- Service: `flipkart-mongodb:27017`.
- Database: `flipkart`.
- PVC: `flipkart-mongodb-data`, dung lượng `2Gi`.
- Connection string của backend:
  `mongodb://flipkart-mongodb:27017/flipkart`.

Cấu hình này phù hợp cho lab Minikube. Production nên dùng MongoDB Atlas hoặc
MongoDB được vận hành chuyên biệt, bật authentication, backup và monitoring.

### 4. Tạo Secret ngoài Git

Không commit secret thật vào repository.

Tối thiểu cần:

```text
JWT_SECRET
JWT_EXPIRE
COOKIE_EXPIRE
```

Tùy tính năng sử dụng còn cần Cloudinary, SendGrid và Paytm credentials.

Ví dụ tạo Secret cho lab:

```bash
kubectl create namespace flipkart

kubectl create secret generic flipkart-backend-secrets \
  -n flipkart \
  --from-literal=JWT_SECRET='<jwt-secret>' \
  --from-literal=JWT_EXPIRE='7d' \
  --from-literal=COOKIE_EXPIRE='5'
```

### 5. Push GitOps manifests

```bash
git add cloud/w9/w9-sang-gitops-final/argocd/apps
git add cloud/w9/w9-sang-gitops-final/flipkart
git commit -m "[W9-Lab] Add Flipkart GitOps application"
git push origin main
```

Root Application sẽ phát hiện hai child Application:

- `flipkart-backend` ở sync wave `0`.
- `flipkart-frontend` ở sync wave `1`.

Frontend dùng Nginx để phục vụ React và chuyển tiếp `/api/*` đến Service
`flipkart-backend:4000`.

## Kiểm tra

```bash
kubectl get applications -n argocd
kubectl get deployment,pods,service,pvc -n flipkart
kubectl rollout status deployment/flipkart-backend -n flipkart --timeout=300s
kubectl rollout status deployment/flipkart-frontend -n flipkart --timeout=300s
```
