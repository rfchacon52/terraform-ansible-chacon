#----------------------------
# EKS 
#---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31.6"
  cluster_name = "EKS-DEV" 
  cluster_version = "1.31"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  enable_irsa = true

  cluster_addons = {
    vpc-cni                = {most_recent = true} 
    coredns                = {most_recent = true}
    eks-pod-identity-agent = {most_recent = true}
    kube-proxy             = {most_recent = true}
    aws-ebs-csi-driver     = {most_recent = true}
  }

bootstrap_self_managed_addons = false


  vpc_id      = module.vpc.vpc_id
  subnet_ids  =  module.vpc.private_subnets


 eks_managed_node_group_defaults = {
    disk_size = 50
  }

 eks_managed_node_groups = {
    node_grp1 = {
      instance_types = ["t2.small"]
      ami_type       = "AL2_x86_64"
      min_size = 1
      max_size = 5 
      desired_size = 2
      
     labels = {
        role = "general"
      }

    }
   }


  tags = {
    Environment = "Dev"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
