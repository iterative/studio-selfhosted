terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "$TF_BUCKET"
    key    = "ingress-controller/terraform.tfstate"
    region = "$AWS_REGION"
  }
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "ingress_nginx" {
  create_namespace = true
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.4.2"

  values = [
    "${file("values/ingress-nginx.yaml")}"
  ]
}
