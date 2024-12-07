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
#------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
#-----------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31" 
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
      min_size = 1
      max_size = 5
     desired_size = 1 
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

