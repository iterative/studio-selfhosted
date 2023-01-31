#!/usr/bin/env bash

## expect:
# TF_BUCKET (S3 bucket for Terraform states)
# ADMIN_IAM_ROLE (IAM role which gets admin access to the EKS cluster)
# CREATE_VPC (create a new VPC - true/false)
# VPC_NAME (name of VPC)
# CLUSTER_NAME (name of EKS cluster)
# AWS_REGION

for orig_f in $(find . -name '*.tf' -or -name "*.tfvars")
do
  envsubst < "${orig_f}" > "${orig_f}.tmp" && mv "${orig_f}.tmp" ${orig_f};
done
