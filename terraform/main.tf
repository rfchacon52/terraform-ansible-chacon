# main.tf

# --- Locals ---
data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name   = var.cluster_name
  region = var.region
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    EKSCluster = local.name
    Project    = "EKSAutoMode"
    ManagedBy  = "Terraform"
  }
}

# --- VPC Module ---
# Creates the VPC, public/private subnets, NAT Gateway, Internet Gateway
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0" # Specify the version

  name    = local.name
  cidr    = local.vpc_cidr
  azs     = local.azs

  # Define public and private subnets within the VPC CIDR
  public_subnets  = [for i, v in local.azs : cidrsubnet(local.vpc_cidr, 8, i)] # E.g., 10.0.0.0/24, 10.0.1.0/24
  private_subnets = [for i, v in local.azs : cidrsubnet(local.vpc_cidr, 8, i + length(local.azs))] # E.g., 10.0.2.0/24, 10.0.3.0/24

  enable_nat_gateway   = true
  single_nat_gateway   = true # A single NAT Gateway for cost efficiency
  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw           = true # Create Internet Gateway for public subnets
  one_nat_gateway_per_az = false # Override default to have only one NAT Gateway

  # Required tags for EKS to discover subnets for Load Balancers
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"             = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}"     = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}


# --- EKS Cluster Module ---
# This is where the "Auto Mode" (autoscaling) is configured for the node group.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31" # Ensure this version is compatible with your cluster_version

  cluster_name                     = local.name
  cluster_version                  = var.eks_cluster_version
  cluster_endpoint_private_access  = true # Allow internal VPC access to API server
  cluster_endpoint_public_access   = true # Allow external access to API server (restricted by SG)
  enable_cluster_creator_admin_permissions = true # Grants admin permissions to the IAM user/role running Terraform
  enable_irsa                      = true # Enable IAM Roles for Service Accounts (Crucial for add-ons)

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets # Place worker nodes in private subnets for security

 cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

}
# --- EKS Blueprints Addons Module ---
# Deploys essential EKS add-ons and configures their IRSA roles.
# This assumes you want to use the `eks_blueprints_addons` module.
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.21.0" # Ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn # Critical for IRSA setup by addons


  # Enable AWS Load Balancer Controller (Helm-based add-on)
  enable_aws_load_balancer_controller = true

  # Optional: Enable ArgoCD if you want to deploy it via this module
  # enable_argocd = true
  # argocd_helm_config = {
  #   values = [
  #     jsonencode({
  #       server = {
  #         service = {
  #           type     = "NodePort"
  #           nodePort = 30660
  #         }
  #       }
  #     })
  #   ]
  # }

  tags = local.tags
}
