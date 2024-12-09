#----------------------------
# EKS 
#---------------------------
module "ek_al2023" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.31"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

 cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  subnet_ids =  module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

eks_managed_node_groups = {
    node_grp1 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t2.small"]
      ami_type       = "AL2_x86_64"
      min_size = 2
      max_size = 5
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2

    }
  }
}  
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
