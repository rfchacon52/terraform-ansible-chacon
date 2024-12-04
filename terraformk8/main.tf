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
#---------------------------------
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}
#-------------------------------
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
#-------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}
#------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
#---------------------------
module "eks-kubeconfig" {
  source     = "hyperbadger/eks-kubeconfig/aws"
  version    = "1.0.0"

  depends_on = [module.eks]
  cluster_id =  module.eks.cluster_id
  }
#---------------------------
resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig_${var.cluster_name}"
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
  version = "20.30.1" 
  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

 cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

 eks_managed_node_group_defaults = {
     ami_type = "AL2_x86_64"
 }


 eks_managed_node_groups = {
    one  = {
      name = "node-group-1"
      instance_types = ["t3.small"]
      min_size = 2
      max_size = 5
     desired_size = 2 
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

