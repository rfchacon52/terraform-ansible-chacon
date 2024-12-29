#----------------------------
# EKS 
#---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  cluster_endpoint_public_access           = true

  vpc_id      = module.vpc.vpc_id
  subnet_ids  =  module.vpc.private_subnets

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  enable_cluster_creator_admin_permissions = true


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}
