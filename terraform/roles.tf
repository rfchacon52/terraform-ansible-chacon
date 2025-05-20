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