# -----------------------------------------------------------------------------
# MISSING RESOURCE: Node Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "node_role" {
  name = "eks-auto-node-role-use1"

  # Trust Policy: Allows EC2 instances (the nodes) to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# -----------------------------------------------------------------------------
# REQUIRED POLICIES for Auto Mode Nodes
# -----------------------------------------------------------------------------

# 1. Minimal Worker Node Policy (New for Auto Mode)
# This replaces the old "AmazonEKSWorkerNodePolicy"
resource "aws_iam_role_policy_attachment" "node_minimal" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node_role.name
}

# 2. ECR Pull Policy
# Required so nodes can download your Docker images
resource "aws_iam_role_policy_attachment" "node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node_role.name
}

# 3. Access Entry (The "Who")
resource "aws_eks_access_entry" "my_admin_access" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::767397937300:user/terraform"
  type          = "STANDARD"
}

# 4. Policy Association (The "What Permissions") -> ADD THIS HERE
resource "aws_eks_access_policy_association" "my_admin_policy" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.my_admin_access.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type       = "cluster"
  }
}


