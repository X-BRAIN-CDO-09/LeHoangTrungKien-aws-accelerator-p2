#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf '[w10-security-hardening] %s\n' "$*"
}

apply_file() {
  local file="$1"
  log "apply ${file#"$ROOT_DIR"/}"
  kubectl apply -f "$file"
}

apply_dir() {
  local dir="$1"
  log "apply ${dir#"$ROOT_DIR"/}/"
  kubectl apply -f "$dir"
}

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required" >&2
  exit 1
fi

log "using context: $(kubectl config current-context)"

apply_file "$ROOT_DIR/base/00-namespaces.yaml"

apply_dir "$ROOT_DIR/rbac"

apply_file "$ROOT_DIR/policies/gatekeeper/20-template-required-resources.yaml"
apply_file "$ROOT_DIR/policies/gatekeeper/21-template-required-security-context.yaml"
apply_file "$ROOT_DIR/policies/gatekeeper/22-template-disallow-latest-tag.yaml"
apply_file "$ROOT_DIR/policies/gatekeeper/23-template-disallow-privileged.yaml"
apply_file "$ROOT_DIR/policies/gatekeeper/24-constraints-enforce-workload-standards.yaml"

apply_dir "$ROOT_DIR/secrets/eso"

apply_file "$ROOT_DIR/platform/60-resourcequota-flipkart.yaml"
apply_file "$ROOT_DIR/platform/61-limitrange-flipkart.yaml"

if [[ "${APPLY_KYVERNO_VERIFY_IMAGES:-false}" == "true" ]]; then
  apply_file "$ROOT_DIR/supply-chain/signing/50-kyverno-verify-signed-images.yaml"
else
  log "skip Kyverno verifyImages policy; set APPLY_KYVERNO_VERIFY_IMAGES=true after replacing the Cosign public key"
fi

if [[ "${RUN_POLICY_TESTS:-false}" == "true" ]]; then
  log "run policy test workloads"
  kubectl apply -f "$ROOT_DIR/policy-test-workloads/90-insecure-workload-denied.yaml" || true
  kubectl apply -f "$ROOT_DIR/policy-test-workloads/91-secure-workload-allowed.yaml"
fi

log "done"
