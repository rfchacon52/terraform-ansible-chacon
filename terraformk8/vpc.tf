# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
#------------------------------------
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      site-name = "Chacon-west-1"
    }
  }
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

#--------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

#--------------------------
module "eks-kubeconfig" {
  source  = "hyperbadger/eks-kubeconfig/aws"
  version = "1.0.0"

  depends_on = [module.eks]
  cluster_id = module.eks.cluster_id
}

#--------------------------
# vpc module for eks
#----------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"
  name    = "EKS-VPC" 
  cidr    = "10.0.0.0/16"
  azs     = data.aws_availability_zones.available.names

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

