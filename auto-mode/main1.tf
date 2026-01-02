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

# -----------------------------------------------------------------------------
# 2. IAM Roles (Auto Mode Specifics)
# -----------------------------------------------------------------------------

# --- Cluster Role ---
resource "aws_iam_role" "cluster_role" {
  name = "eks-auto-cluster-role-use1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# Standard EKS Policy
resource "aws_iam_role_policy_attachment" "policy_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# AUTO MODE REQUIRED: Allows EKS to manage EC2 nodes
resource "aws_iam_role_policy_attachment" "policy_compute" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster_role.name
}

# AUTO MODE REQUIRED: Allows EKS to manage EBS volumes
resource "aws_iam_role_policy_attachment" "policy_storage" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster_role.name
}

# AUTO MODE REQUIRED: Allows EKS to manage Load Balancers
resource "aws_iam_role_policy_attachment" "policy_lb" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster_role.name
}

# AUTO MODE REQUIRED: Allows EKS to manage Networking (VPC CNI)
resource "aws_iam_role_policy_attachment" "policy_networking" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster_role.name
}

# --- Node Role ---
# EKS Auto Mode uses this role for the worker nodes it automatically creates
resource "aws_iam_role" "node_role" {
  name = "eks-auto-node-role-use1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Minimal policy required for Auto Mode nodes
resource "aws_iam_role_policy_attachment" "node_minimal" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node_role.name
}

# -----------------------------------------------------------------------------
# 3. EKS Cluster (Auto Mode Configuration)
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = "eks-auto-use1"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # --- EKS Auto Mode Blocks ---

  # 1. Compute: Automatically manage nodes
  compute_config {
    enabled       = true
    node_pool     = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.node_role.arn
  }

  # 2. Storage: Automatically manage EBS CSI Driver
  storage_config {
    block_storage {
      enabled = true
    }
  }

  # 3. Networking: Automatically manage Load Balancer Controller
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  # Dependencies ensuring permissions exist before cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.policy_cluster,
    aws_iam_role_policy_attachment.policy_compute,
    aws_iam_role_policy_attachment.policy_storage,
    aws_iam_role_policy_attachment.policy_lb,
    aws_iam_role_policy_attachment.policy_networking
  ]
}

# -----------------------------------------------------------------------------
# 4. Outputs
# -----------------------------------------------------------------------------
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "update_kubeconfig_command" {
  value = "aws eks update-kubeconfig --region us-east-1 --name ${aws_eks_cluster.main.name}"
}

