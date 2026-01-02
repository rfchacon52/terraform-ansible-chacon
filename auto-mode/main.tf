
# Use the community terraform-aws-modules/vpc/aws module for a standard VPC setup
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  name = "eks-auto-mode-vpc"
  cidr = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  # Tag subnets for EKS Auto Mode discovery
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery" = "eks-auto-cluster" # Cluster name below
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

# Create an IAM role for the EKS cluster control plane
resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role-auto"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach the required AmazonEKSClusterPolicy to the role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster.name
}

# The main EKS cluster resource with Auto Mode enabled
resource "aws_eks_cluster" "cluster" {
  name = "eks-auto-cluster"
  role_arn = aws_iam_role.cluster.arn
  version = "1.32" # EKS Auto Mode requires Kubernetes version 1.29 or higher

  vpc_config {
    subnet_ids = module.vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access = true
  }

access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false 
  }

  # --- YOU MUST INCLUDE ALL 3 BLOCKS BELOW ---

  # 1. Compute Config
  compute_config {
    enabled       = true
    node_pools    = ["general-purpose", "system"]
  }

  # 2. Storage Config (REQUIRED for Auto Mode)
  storage_config {
    block_storage {
      enabled = true
    }
  }

  # 3. Network Config (REQUIRED for Auto Mode)
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }
}

