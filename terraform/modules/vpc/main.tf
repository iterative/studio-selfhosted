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

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  count   = var.create_vpc ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.vpc_name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.vpc_name}" = "shared"
    "kubernetes.io/role/elb"                = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.vpc_name}" = "shared"
    "kubernetes.io/role/internal-elb"       = 1
  }
}

# Existing VPC
data "aws_vpc" "existing_vpc" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "existing_vpc" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc[0].id]
  }
  tags = {
    Type = "private"
  }
}
