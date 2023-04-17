#!/bin/bash
set -euxo pipefail

LOG_DIR=/tmp/studio-support
mkdir "$LOG_DIR"

get_logs() {
    POD_NAME=$(kubectl get pods --namespace studio -l "app.kubernetes.io/name=studio-$1,app.kubernetes.io/instance=studio" -o jsonpath="{.items[0].metadata.name}")
    kubectl logs $POD_NAME -n studio
}

get_logs backend > "$LOG_DIR/backend.txt"
get_logs beat > "$LOG_DIR/beat.txt"
get_logs ui > "$LOG_DIR/ui.txt"
get_logs worker > "$LOG_DIR/worker.txt"

tar -zcvf /tmp/studio-support.tar.gz "$LOG_DIR"
rm -rf "$LOG_DIR"
