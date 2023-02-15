#!/bin/bash

PS4='studio-selfhosted:setup_ubuntu.sh: '
set -eux
set -o pipefail

# Add Helm Iterative Repository
helm repo add iterative https://helm.iterative.ai
helm repo update

# Add Helm default values from latest release
helm pull iterative/studio
tar -zxvf studio-*.tgz -C /tmp
mv /tmp/studio/values.yaml ~/studio-values.yaml
rm studio-*.tgz
