# Install Checklist - Docker, kubectl, minikube

## Mục Tiêu

Chuẩn bị laptop để T5 có thể chạy lab minikube.

## Cần Có

- Docker Desktop trên Mac/Windows hoặc Docker Engine trên Linux.
- kubectl.
- minikube.

## Kiểm Tra Version

```bash
docker --version
kubectl version --client
minikube version
```

## Kiểm Tra Cluster Local

```bash
minikube start
minikube status
kubectl get nodes
kubectl get pods -A
```

## Evidence

Ghi lại:

- Docker version.
- kubectl client version.
- minikube version.
- Output `kubectl get nodes`.
- Nếu lỗi, ghi lỗi và cách xử lý đã thử.

