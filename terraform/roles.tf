###########################################
# Apply EKS Cluster Roles 
############################################
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
  role  = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

###########################################
# Apply EBS CSI Driver  
############################################
resource "aws_iam_role" "ebs-csi-driver-role" {
  name = "ebs-csi-driver-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "sts:OIDCProvider": "oidc.eks.us-east-1.amazonaws.com/id/767397937300" # Replace
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_cni" {
  role  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # AWS managed policy
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_worker" {
  role  = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # AWS managed policy
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment_ecr" {
  role  = aws_iam_role.eks_nodegroup_role.name
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

