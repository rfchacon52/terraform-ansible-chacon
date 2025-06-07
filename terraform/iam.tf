# iam.tf

# --- EKS Cluster IAM Role (for the EKS Control Plane) ---
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attach" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- EKS Node Group IAM Role (for the EC2 worker instances) ---
resource "aws_iam_role" "eks_node_role" {
  name = "${local.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_registry_policy_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# NOTE: The AmazonEKS_CNI_Policy is often attached to the `aws-node` service account via IRSA
# by the `vpc-cni` addon if you enable it. If not, you might attach it here to the node role.
 resource "aws_iam_role_policy_attachment" "eks_node_cni_policy_attach" {
   role       = aws_iam_role.eks_node_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
 }
