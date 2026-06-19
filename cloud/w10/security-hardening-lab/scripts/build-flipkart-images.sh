#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
APP_DIR="${ROOT_DIR}/cloud/w9/w9-lab-gitops-final/app"
BACKEND_MANIFEST="${ROOT_DIR}/cloud/w9/w9-lab-gitops-final/flipkart/k8s/backend/backend-rollout.yaml"
FRONTEND_MANIFEST="${ROOT_DIR}/cloud/w9/w9-lab-gitops-final/flipkart/k8s/frontend/frontend.yaml"

REGISTRY="${REGISTRY:-docker.io}"
IMAGE_NAMESPACE="${IMAGE_NAMESPACE:-kienlht}"
TAG="${TAG:-$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"
PUSH="${PUSH:-false}"
LOAD_KIND="${LOAD_KIND:-false}"
LOAD_MINIKUBE="${LOAD_MINIKUBE:-false}"
UPDATE_MANIFESTS="${UPDATE_MANIFESTS:-false}"

BACKEND_IMAGE="${REGISTRY}/${IMAGE_NAMESPACE}/flipkart-backend:${TAG}"
FRONTEND_IMAGE="${REGISTRY}/${IMAGE_NAMESPACE}/flipkart-frontend:${TAG}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Thiếu command: $1" >&2
    exit 1
  fi
}

replace_image_line() {
  local file="$1"
  local image_name="$2"
  local new_image="$3"

  sed -i -E "s#image: .*${image_name}[^[:space:]]*#image: ${new_image}#" "$file"
}

require_cmd docker

cd "$ROOT_DIR"

echo "Build tag: ${TAG}"
echo "Backend image: ${BACKEND_IMAGE}"
echo "Frontend image: ${FRONTEND_IMAGE}"
echo

docker build \
  -f "${APP_DIR}/Dockerfile.backend" \
  -t "${BACKEND_IMAGE}" \
  "${APP_DIR}"

docker build \
  -f "${APP_DIR}/Dockerfile.frontend" \
  -t "${FRONTEND_IMAGE}" \
  "${APP_DIR}"

if [[ "$PUSH" == "true" ]]; then
  echo
  echo "Push images lên registry..."
  docker push "${BACKEND_IMAGE}"
  docker push "${FRONTEND_IMAGE}"
fi

if [[ "$LOAD_KIND" == "true" ]]; then
  require_cmd kind
  echo
  echo "Load images vào kind cluster..."
  kind load docker-image "${BACKEND_IMAGE}"
  kind load docker-image "${FRONTEND_IMAGE}"
fi

if [[ "$LOAD_MINIKUBE" == "true" ]]; then
  require_cmd minikube
  echo
  echo "Load images vào minikube..."
  minikube image load "${BACKEND_IMAGE}"
  minikube image load "${FRONTEND_IMAGE}"
fi

if [[ "$UPDATE_MANIFESTS" == "true" ]]; then
  echo
  echo "Cập nhật image tag trong GitOps manifests..."
  replace_image_line "$BACKEND_MANIFEST" "flipkart-backend" "$BACKEND_IMAGE"
  replace_image_line "$FRONTEND_MANIFEST" "flipkart-frontend" "$FRONTEND_IMAGE"
  echo "Đã cập nhật:"
  echo "  ${BACKEND_MANIFEST}"
  echo "  ${FRONTEND_MANIFEST}"
fi

echo
echo "Hoàn tất build image."
echo
echo "Các cách dùng thường gặp:"
echo "  Local kind:      LOAD_KIND=true UPDATE_MANIFESTS=true $0"
echo "  Local minikube:  LOAD_MINIKUBE=true UPDATE_MANIFESTS=true $0"
echo "  Registry push:   PUSH=true UPDATE_MANIFESTS=true $0"
echo
echo "Sau khi UPDATE_MANIFESTS=true, commit và push manifest để ArgoCD sync."
