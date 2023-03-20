#/bin/bash

PS4='studio-selfhosted:setup_root.sh: '
set -eux
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

# Install K3s - script uploaded with packer
K3S_VERSION=v1.25.7+k3s1
INSTALL_K3S_SKIP_START="true" INSTALL_K3S_EXEC="--disable=traefik"  K3S_KUBECONFIG_MODE="644" INSTALL_K3S_VERSION=${K3S_VERSION} sh /tmp/k3s.sh -
echo KUBECONFIG="/etc/rancher/k3s/k3s.yaml" >> /etc/environment

# Install k9s
K9S_VERSION=v0.27.3
cd /tmp
curl --silent -L https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o /tmp/k9s_Linux_x86_64.tar.gz
echo "f774bb75045e361e17a4f267491c5ec66f41db7bffd996859ffb1465420af249  k9s_Linux_x86_64.tar.gz" > /tmp/k9s.sha256
sha256sum -c /tmp/k9s.sha256
tar -zxvf /tmp/k9s_Linux_x86_64.tar.gz  -C /tmp
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
bash /tmp/helm3.sh

# Add Helm Iterative Repository
helm repo add iterative https://helm.iterative.ai

