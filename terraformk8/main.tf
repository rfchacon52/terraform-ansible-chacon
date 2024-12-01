# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#--------------------------------
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      site-name = "Chacon-west-1"
    }
  }
}
#-----------------------------
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
#---------------------------
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
#---------------------------
data "aws_availability_zones" "available" {
  state = "available"
}
#----------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"
  name    = "${var.cluster_name}-vpc"
  cidr    = "172.16.0.0/16"
  azs                     = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

#-----------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3" 

  cluster_name    = var.cluster_name
  cluster_version = "1.24"
  subnet_ids        = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
    first = {
      desired_capacity = 2
      max_capacity     = 5 
      min_capacity     = 1

      instance_type = var.instance_type
    }
  }
  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }
}

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy-${var.cluster_name}"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.worker_policy.arn
  role       = each.value.iam_role_name
}


