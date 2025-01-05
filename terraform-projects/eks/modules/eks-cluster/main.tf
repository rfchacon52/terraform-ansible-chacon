################################################################################
# EKS Cluster
################################################################################
#------------------------------------
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      site-name = "Chacon-west-1"
    }
  }
}
#--------------------------
data "aws_availability_zones" "available" {
  state = "available"

  cluster_name = var.cluster_name 

#--------------------------
#  module for eks
#----------------------------
module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name = var.cluster_name 
  cluster_version = "1.31"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true
  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {}

  cluster_addons = {
    vpc-cni                = {most_recent = true} 
    coredns                = {most_recent = true}
    eks-pod-identity-agent = {most_recent = true}
    kube-proxy             = {most_recent = true}
    aws-ebs-csi-driver     = {most_recent = true}
  }

 vpc_id      = module.vpc.vpc_id
 subnet_ids  =  module.vpc.private_subnets

 eks_managed_node_group_defaults = {
    disk_size = 50
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }


eks_managed_node_groups = {
    node_grp1 = {
      instance_types = ["t2.medium"]
      ami_type       = "AL2_x86_64"
      min_size = 1
      max_size = 3 
      desired_size = 2
    }
   }
  tags = {
    Environment = "Dev"
  }
}

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = var.rolearn
      username = "skanyi"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    env       = "dev"
    terraform = "true"
  }
}

