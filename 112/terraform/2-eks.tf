# terraform/eks.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"

  cluster_name    = var.cluster_name 
  cluster_version = var.cluster_version 

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"
  enable_irsa = true

  bootstrap_self_managed_addons = false
   cluster_addons = {
     coredns                = {}
     eks-pod-identity-agent = {}
     kube-proxy             = {}
     vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"
    }
  }

  tags = {
    Environment = "DEV"
  }
}

