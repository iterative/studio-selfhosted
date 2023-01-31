terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}
provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.21.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  managed_node_groups = {
    default = {
      node_group_name    = "default"
      instance_types     = ["t3.xlarge"]
      min_size           = 2
      max_size           = 4
      desired_size       = 2
      subnet_ids         = var.private_subnet_ids
      kubelet_extra_args = "--kube-reserved cpu=500m,memory=1Gi,ephemeral-storage=1Gi --system-reserved cpu=500m,memory=1Gi,ephemeral-storage=1Gi --eviction-hard memory.available<0.5Gi,nodefs.available<10%"
    }
  }

  platform_teams = {
    admins = {
      users = var.admin_users_arns
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  depends_on = [module.eks_blueprints.managed_node_groups]
  source     = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.21.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "podLabels.prometheus\\.io/scrape",
        value = "true",
        type  = "string",
      }
    ]
  }
}
