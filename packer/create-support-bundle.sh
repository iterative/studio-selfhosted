#!/bin/bash
set -euxo pipefail

NAMESPACE=studio
LOG_DIR=/tmp/studio-support

usage () {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "  --namespace <namespace>"
}

while [ $# -ne 0 ]; do
  case $1 in
    --namespace)
      shift 1
      NAMESPACE=$1
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 0
      ;;
  esac
done

mkdir -p "$LOG_DIR"

k8s_cm_hostname_to_url() {
  kubectl get configmap/studio --namespace $NAMESPACE -o=jsonpath="{.data.$1}" | sed -E 's#^(https?://)?([^:/?]+).*#\2#'
}

get_logs() {
  POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app.kubernetes.io/name=studio-$1,app.kubernetes.io/instance=studio" -o jsonpath="{.items[0].metadata.name}")
  kubectl logs $POD_NAME --namespace $NAMESPACE
}

get_hostname() {
  nslookup "$1"
  dig "$1"
}

# Kubernetes
get_logs backend > "$LOG_DIR/backend.txt"
get_logs beat > "$LOG_DIR/beat.txt"
get_logs ui > "$LOG_DIR/ui.txt"
get_logs worker > "$LOG_DIR/worker.txt"

# DNS resolution
STUDIO_HOSTNAME=$(k8s_cm_hostname_to_url "UI_URL")
get_hostname "$STUDIO_HOSTNAME" > "$LOG_DIR/dns_studio.txt"

GITLAB_HOSTNAME=$(k8s_cm_hostname_to_url "GITLAB_URL")
if [ -n "$GITLAB_HOSTNAME" ]; then
  get_hostname "$GITLAB_HOSTNAME" > "$LOG_DIR/dns_gitlab.txt"
fi

GITHUB_HOSTNAME=$(k8s_cm_hostname_to_url "GITHUB_URL")
if [ -n "$GITHUB_HOSTNAME" ]; then
  get_hostname "$GITHUB_HOSTNAME" > "$LOG_DIR/dns_github.txt"
fi

BITBUCKET_HOSTNAME=$(k8s_cm_hostname_to_url "BITBUCKET_URL")
if [ -n "$BITBUCKET_HOSTNAME" ]; then
  get_hostname "$BITBUCKET_HOSTNAME" > "$LOG_DIR/dns_bitbucket.txt"
fi

tar -zcvf /tmp/studio-support.tar.gz "$LOG_DIR"
rm -rf "$LOG_DIR"
