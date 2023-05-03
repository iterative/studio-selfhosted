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

get_logs() {
    POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app.kubernetes.io/name=studio-$1,app.kubernetes.io/instance=studio" -o jsonpath="{.items[0].metadata.name}")
    kubectl logs $POD_NAME --namespace $NAMESPACE
}

get_logs backend > "$LOG_DIR/backend.txt"
get_logs beat > "$LOG_DIR/beat.txt"
get_logs ui > "$LOG_DIR/ui.txt"
get_logs worker > "$LOG_DIR/worker.txt"

tar -zcvf /tmp/studio-support.tar.gz "$LOG_DIR"
rm -rf "$LOG_DIR"
