# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# 1. Create a VPC using the terraform-aws-modules/vpc module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0" # Use the latest version

  name = "my-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"] # Replace with your desired AZs
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway = true
}

# 2. Create an EKS Cluster using the terraform-aws-modules/eks/aws module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0" # Use the latest version

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.29" # Specify your desired Kubernetes version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets_ids # Use private subnets for nodes

  # Use the EKS cluster role created below
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cluster_security_group   = true

  # Managed node group configuration
  manage_nodegroup = true
  eks_managed_node_groups = {
    default = {
      name = "default"
      instance_types = ["t2.small"] # Choose your instance type
      desired_capacity = 2
      min_size     = 1
      max_size     = 4
      node_group_subnet_ids = module.vpc.private_subnets_ids
      # Ensure nodes use the nodegroup role
      node_group_role_arn = aws_iam_role.eks_nodegroup_role.arn
    }
  }
  #EKS Addons
  enable_default_addons = true
}



# 3. Define the EKS Cluster Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach the necessary policy to the cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role_name  = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # AWS managed policy
}

# 4. Define the Node Group Role
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks-nodegroup-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach the necessary policies to the node group role
resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_worker" {
  role_name  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # AWS managed policy
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_cni" {
  role_name  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # AWS managed policy
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_ecr" {
  role_name  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # AWS managed policy
}

# 5. Deploy essential add-ons using the eks_blueprints_addons module
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" # Use a recent version

  cluster_name    = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }
}

# 6. Configure the Kubernetes Provider
provider "kubernetes" {
  host                  = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                 = data.aws_eks_cluster_auth.cluster.token
  alias = "k8s"
}

# 7. Get the Kubernetes Authentication Token
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

