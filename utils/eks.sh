#!/bin/sh
set -euxo pipefail

# Download eksctl
if [ ! -f "eksctl" ]; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
fi

# Set up Kubernetes cluster
CLUSTER=iterative-studio
EXISTS=$(./eksctl get cluster --region us-east-2 | grep "$CLUSTER" || echo -n "Not found")

if [ "$EXISTS" == "Not found" ]; then
    ./eksctl create cluster \
        -f cluster.yaml \
        --set-kubeconfig-context
fi

# Set up Load balancer
# wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/nlb-with-tls-termination/deploy.yaml


