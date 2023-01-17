#!/bin/sh
set -euxo pipefail

REGION="us-east-2"
EKSCTL_URL="https://github.com/weaveworks/eksctl/releases/download/v0.125.0/eksctl_Linux_amd64.tar.gz"
EKSCTL_SHASUM="341d1a9f60d07103aeb5ae3618d5d10f1a02897bc91ea368bd4edf3779a24d5e"
HELM_URL="https://get.helm.sh/helm-v3.10.3-linux-amd64.tar.gz"
HELM_SHASUM="950439759ece902157cf915b209b8d694e6f675eaab5099fb7894f30eeaee9a2"

# Download eksctl
if [ ! -f "eksctl" ]; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
fi

# Download Helm
#if [ ! -f "helm" ]; then
#    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
#fi

# Set up Kubernetes cluster
CLUSTER=iterative-studio
EXISTS=$(./eksctl get cluster --region "$REGION" | grep "$CLUSTER" || echo -n "Not found")

if [ "$EXISTS" == "Not found" ]; then
    ./eksctl create cluster \
        -f cluster.yaml \
        --set-kubeconfig-context
fi

# Get cluster VPC CIDR
VPC_CIDR=$(./eksctl get cluster --region "$REGION" --name iterative-studio -o json | jq -r '.[].ResourcesVpcConfig.PublicAccessCidrs[0]')

# Set up ingress-nginx
wget -O /tmp/ingress-nginx.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/nlb-with-tls-termination/deploy.yaml
sed -i "s|XXX.XXX.XXX/XX|${VPC_CIDR}|" /tmp/ingress-nginx.yaml
kubectl apply -f /tmp/ingress-nginx.yaml

# Add Iterative Helm repository
