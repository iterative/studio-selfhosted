#!/bin/bash

PS4='studio-selfhosted:setup_ubuntu.sh: '
set -eux
set -o pipefail

# Add Helm Iterative Repository
helm repo add iterative https://helm.iterative.ai
