terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "$TF_BUCKET"
    key    = "eks-cluster/terraform.tfstate"
    region = "$AWS_REGION"
  }
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

provider "aws" {
  region = "$AWS_REGION"


  # Causes errors such as
  # =====================
  # Error: Provider produced inconsistent final plan
  # When expanding the plan for module.eks.module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng to include new values learned so far during apply, provider "registry.terraform.io/hashicorp/aws" produced an invalid new value for
  # .tags_all: new element "kubernetes.io/cluster/iterative-studio-jesper" has appeared.
  #  
  # default_tags {
  #   tags = {
  #     Source = "studio-selfhosted"
  #   }
  # }
}


module "vpc" {
  source = "../modules/vpc"

  create_vpc = var.create_vpc
  vpc_name   = var.vpc_name
  vpc_cidr   = var.vpc_cidr
}

module "eks" {
  source = "../modules/eks"

  cluster_name = var.cluster_name

  vpc_id             = module.vpc.id
  private_subnet_ids = module.vpc.private_subnet_ids

  admin_users_arns = [var.admin_iam_role]
}
