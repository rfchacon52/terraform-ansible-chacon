module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               =  var.cluster_name
  kubernetes_version =  var.cluster_version

  # Optional
  endpoint_public_access = true
  endpoint_private_access = true
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Create just the IAM resources for EKS Auto Mode for use with custom node pools
create_auto_mode_iam_resources = true

enable_irsa = true 

  # Set Auto-mode
  compute_config = {
    enabled = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  access_config {
    # Auto Mode requires this to be set to false
    bootstrap_self_managed_addons = false
  }
  tags = {
    Environment = "Dev"
    Terraform   = "true"
  }

}

