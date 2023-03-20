#!/bin/bash

PS4='studio-selfhosted:setup_root.sh: '
set -eux
set -o pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

export DEBIAN_FRONTEND=noninteractive

# Install K3s - script uploaded with packer
K3S_VERSION=v1.25.7+k3s1
K3S_KUBECONFIG_MODE="644"
INSTALL_K3S_VERSION=${K3S_VERSION}
INSTALL_K3S_SKIP_START="true"

INSTALL_K3S_EXEC=""
INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --disable=traefik"
INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --kube-reserved cpu=500m,memory=1Gi,ephemeral-storage=1Gi"
INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --system-reserved cpu=500m,memory=1Gi,ephemeral-storage=1Gi"
INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --eviction-hard memory.available<0.5Gi,nodefs.available<10%"

sh /home/ubuntu/.studio_install/k3s.sh -
echo KUBECONFIG="/etc/rancher/k3s/k3s.yaml" >> /etc/environment

# Install k9s
K9S_VERSION=v0.27.3
cd /tmp
curl --silent -L https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz -o /tmp/k9s_Linux_amd64.tar.gz
echo "b0eb5fb0decedbee5b6bd415f72af8ce6135ffb8128f9709bc7adcd5cbfa690b  k9s_Linux_amd64.tar.gz" > /tmp/k9s.sha256
sha256sum -c /tmp/k9s.sha256
tar -zxvf /tmp/k9s_Linux_amd64.tar.gz  -C /tmp
mv /tmp/k9s /usr/local/bin/
cd /root

# Install Ingress Nginx
mkdir -p /var/lib/rancher/k3s/server/manifests/
cat << YAML >> /var/lib/rancher/k3s/server/manifests/ingress-nginx.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: ingress-nginx
  namespace: kube-system
spec:
  repo: https://kubernetes.github.io/ingress-nginx
  chart: ingress-nginx
  version: 4.4.2
  targetNamespace: ingress-nginx
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: ingress-nginx
  namespace: kube-system
spec:
  valuesContent: |-
    controller:
      watchIngressWithoutClass: true
YAML

cat << YAML >> /var/lib/rancher/k3s/server/manifests/studio.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: studio
YAML

# Install Helm - script uploaded with packer
bash /home/ubuntu/.studio_install/helm3.sh

# Add Helm Iterative Repository
helm repo add iterative https://helm.iterative.ai

