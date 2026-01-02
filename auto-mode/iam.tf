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
