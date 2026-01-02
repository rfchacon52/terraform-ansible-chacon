# -----------------------------------------------------------------------------
# 1. Network (VPC)
# -----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-auto-vpc-us-east-1"
  cidr = "10.0.0.0/16"

  # us-east-1 specific Availability Zones
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Keeps costs down for demos; set to false for prod
  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw             = true
  one_nat_gateway_per_az = false

  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
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
  version = "1.33" # EKS Auto Mode requires Kubernetes version 1.29 or higher

  vpc_config {
    subnet_ids = module.vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access = true
  }

  # Enable EKS Auto Mode
  compute_config {
    enabled = true
  }
}

# Output the cluster name to configure kubectl
output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.cluster.name} --region ${data.aws_region.current.name}"
}

# Data source for current AWS region
data "aws_region" "current" {}

