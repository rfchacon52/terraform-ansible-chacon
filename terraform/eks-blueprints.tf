module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.25.0"

  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  enable_irsa       = true

# vpc and private subnet
  vpc_id = module.vpc_id
  private_subnet_ids  =  module.vpc.private_subnets

# Add managed node groups
  managed_node_groups = {
    node_grp1 = {
      capacity_type = "ON_DEMAND"
      node_group_name = "general"
      instance_types = ["t3.large"]
      min_size = "1"
      max_size = "3"
      desired_size = "2"
    }
   } 

 provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
}


