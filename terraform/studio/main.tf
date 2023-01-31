terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "$TF_BUCKET"
    key    = "studio/terraform.tfstate"
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


resource "helm_release" "studio" {
  name       = "studio"
  repository = "https://helm.iterative.ai"
  chart      = "studio"
  namespace  = "studio"
  version    = "0.1.16"

  values = [
    "${file("values/studio.yaml")}"
  ]
}
