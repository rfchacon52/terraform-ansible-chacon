#----------------------------
# EKS 
#---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name    = "EKS-DEV"
  cluster_version = "1.31"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

bootstrap_self_managed_addons = false
  cluster_addons = {
    vpc-cni                = {} 
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    aws-ebs-csi-driver     = {} 
  }

  vpc_id      = module.vpc.vpc_id
  subnet_ids  =  module.vpc.private_subnets

eks_managed_node_groups = {
    node_grp1 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t2.small"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size = 2
      max_size = 10 
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2
# Needed by the aws-ebs-csi-driver
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
   }
  }

tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
