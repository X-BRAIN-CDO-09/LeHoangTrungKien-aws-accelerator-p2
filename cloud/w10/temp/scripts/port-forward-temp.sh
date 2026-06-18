#!/usr/bin/env bash
set -Eeuo pipefail

MODE="${1:-all}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LOG_DIR="${LOG_DIR:-/tmp/w10-temp-port-forward}"

mkdir -p "$LOG_DIR"

PIDS=()

cleanup() {
  if ((${#PIDS[@]} > 0)); then
    echo
    echo "Dừng các port-forward..."
    kill "${PIDS[@]}" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT INT TERM

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Thiếu command: $1" >&2
    exit 1
  fi
}

port_in_use() {
  local port="$1"

  if command -v lsof >/dev/null 2>&1; then
    lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
    return $?
  fi

  if command -v ss >/dev/null 2>&1; then
    ss -ltn | awk '{print $4}' | grep -Eq "[:.]${port}$"
    return $?
  fi

  return 1
}

service_exists() {
  local namespace="$1"
  local service="$2"
  kubectl get svc "$service" -n "$namespace" >/dev/null 2>&1
}

start_forward() {
  local namespace="$1"
  local service="$2"
  local local_port="$3"
  local remote_port="$4"
  local label="$5"
  local protocol="${6:-http}"
  local log_file="${LOG_DIR}/${namespace}-${service}-${local_port}.log"

  if ! service_exists "$namespace" "$service"; then
    echo "Bỏ qua ${label}: không thấy svc/${service} trong namespace ${namespace}"
    return 0
  fi

  if port_in_use "$local_port"; then
    echo "Bỏ qua ${label}: local port ${local_port} đang được dùng"
    return 0
  fi

  kubectl -n "$namespace" port-forward "svc/${service}" "${local_port}:${remote_port}" >"$log_file" 2>&1 &
  local pid="$!"
  PIDS+=("$pid")

  echo "${label}: ${protocol}://localhost:${local_port}  ->  ${namespace}/svc/${service}:${remote_port}"
  echo "  log: ${log_file}"
}

usage() {
  cat <<'USAGE'
Usage:
  ./cloud/w10/temp/scripts/port-forward-temp.sh [all|app|obs|argocd]

Ports:
  ArgoCD       https://localhost:8080
  Grafana      http://localhost:3000
  Prometheus   http://localhost:9090
  Alertmanager http://localhost:9093
  API          http://localhost:8081

Nhấn Ctrl+C để dừng toàn bộ port-forward.
USAGE
}

if [[ "${MODE}" == "-h" || "${MODE}" == "--help" ]]; then
  usage
  exit 0
fi

case "$MODE" in
  all|app|obs|argocd) ;;
  *)
    usage
    exit 1
    ;;
esac

require_cmd kubectl

cd "$ROOT_DIR"

echo "Kiểm tra cluster context..."
kubectl config current-context >/dev/null
echo "Context: $(kubectl config current-context)"
echo

if [[ "$MODE" == "all" || "$MODE" == "argocd" ]]; then
  start_forward argocd argocd-server 8080 443 "ArgoCD" "https"
fi

if [[ "$MODE" == "all" || "$MODE" == "obs" ]]; then
  start_forward monitoring kube-prometheus-stack-grafana 3000 80 "Grafana"
  start_forward monitoring kube-prometheus-stack-prometheus 9090 9090 "Prometheus"
  start_forward monitoring kube-prometheus-stack-alertmanager 9093 9093 "Alertmanager"
fi

if [[ "$MODE" == "all" || "$MODE" == "app" ]]; then
  start_forward demo api 8081 80 "API"
fi

if ((${#PIDS[@]} == 0)); then
  echo
  echo "Không mở port-forward nào. Kiểm tra service name hoặc port local đang bận."
  exit 1
fi

echo
echo "Port-forward đang chạy. Nhấn Ctrl+C để dừng."
wait
